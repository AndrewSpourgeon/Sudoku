import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../models/leaderboard_entry.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<UserProfile?> getOrCreateCurrentUser() async {
    final user = _auth.currentUser; // was forced non-null
    if (user == null) {
      return null; // auth not ready
    }
    final docRef = _users.doc(user.uid);
    final doc = await docRef.get();
    final authPhoto = user.photoURL;
    if (!doc.exists) {
      final profile = UserProfile.initial(
        user.uid,
        user.displayName,
        user.email,
        photoUrl: authPhoto, // will only persist if allowAvatar later set true
      );
      await docRef.set(profile.toMap());
      return profile;
    }
    // Existing profile
    final existing = UserProfile.fromDoc(user.uid, doc);
    // Only write/refresh photo if consent granted.
    if (authPhoto != null && existing.allowAvatar == true) {
      final data = doc.data();
      final storedPhoto =
          data?['photoUrl'] as String? ?? data?['photoURL'] as String?;
      if (storedPhoto != authPhoto) {
        await docRef.set({
          'photoUrl': authPhoto,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
    return existing;
  }

  Future<Map<String, int>> updateStats({
    required String uid,
    required String level, // 'easy'|'medium'|'hard'
    required bool win,
    required int seconds,
    int ratingDelta = 0, // ignored; will compute internally
  }) async {
    final authUser = _auth.currentUser;
    if (authUser == null || authUser.uid != uid) return {'old': 0, 'new': 0};
    final docRef = _users.doc(uid);
    try {
      // Use the transaction return value to surface the rating changes
      final result = await _firestore.runTransaction((txn) async {
        final snap = await txn.get(docRef);
        final existingOverview =
            (snap.data()?['overview'] as Map<String, dynamic>? ?? {});
        // --- Activity streak (any game per day) ---
        int currentStreak =
            (existingOverview['currentStreak'] as num?)?.toInt() ?? 0;
        int bestStreak = (existingOverview['bestStreak'] as num?)?.toInt() ?? 0;
        Timestamp? lastPlayTs =
            existingOverview['lastPlayTs'] as Timestamp? ??
            existingOverview['lastWinTs'] as Timestamp?; // backward compat
        final nowUtc = DateTime.now().toUtc();
        final today = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
        DateTime? lastPlayDate;
        if (lastPlayTs != null) {
          final d = lastPlayTs.toDate().toUtc();
          lastPlayDate = DateTime.utc(d.year, d.month, d.day);
        }
        if (lastPlayDate == null) {
          currentStreak = 1;
        } else {
          final diff = today.difference(lastPlayDate).inDays;
          if (diff == 0) {
            // already counted today
          } else if (diff == 1) {
            currentStreak += 1;
          } else {
            currentStreak = 1; // gap reset
          }
        }
        if (currentStreak > bestStreak) bestStreak = currentStreak;
        lastPlayTs = Timestamp.fromDate(nowUtc);
        // --- end activity streak ---

        // Prepare profile object
        UserProfile profile;
        if (!snap.exists) {
          profile = UserProfile.initial(
            uid,
            authUser.displayName,
            authUser.email,
          );
        } else {
          profile = UserProfile.fromDoc(uid, snap);
        }

        // previous global rating (before this update)
        final prevGlobalRating =
            profile.easy.rating + profile.medium.rating + profile.hard.rating;

        // Level specific update
        PlayerStats updated;
        int baseDelta;
        switch (level) {
          case 'easy':
            baseDelta = win ? 5 : -5;
            updated = profile.easy.recordGame(
              win: win,
              seconds: seconds,
              ratingDelta: baseDelta,
            );
            profile = profile.copyWith(easy: updated);
            break;
          case 'medium':
            baseDelta = win ? 20 : -7;
            updated = profile.medium.recordGame(
              win: win,
              seconds: seconds,
              ratingDelta: baseDelta,
            );
            profile = profile.copyWith(medium: updated);
            break;
          case 'hard':
            baseDelta = win ? 40 : -12;
            updated = profile.hard.recordGame(
              win: win,
              seconds: seconds,
              ratingDelta: baseDelta,
            );
            profile = profile.copyWith(hard: updated);
            break;
          default:
            throw ArgumentError('Unknown level $level');
        }

        final totalGames =
            profile.easy.gamesPlayed +
            profile.medium.gamesPlayed +
            profile.hard.gamesPlayed;
        final totalWins =
            profile.easy.wins + profile.medium.wins + profile.hard.wins;
        final totalWinPercent = totalGames == 0 ? 0.0 : totalWins / totalGames;
        final totalWinSeconds =
            profile.easy.totalSeconds +
            profile.medium.totalSeconds +
            profile.hard.totalSeconds;
        final overallAvgSeconds = totalWins == 0
            ? 0
            : (totalWinSeconds / totalWins).round();
        final globalRating =
            profile.easy.rating + profile.medium.rating + profile.hard.rating;

        // Win streak (keep separately if needed later)
        int currentWinStreak =
            (existingOverview['currentWinStreak'] as num?)?.toInt() ?? 0;
        int bestWinStreak =
            (existingOverview['bestWinStreak'] as num?)?.toInt() ?? 0;
        Timestamp? lastWinTs = existingOverview['lastWinTs'] as Timestamp?;
        if (win) {
          final todayWin = today; // reuse today
          DateTime? lastWinDate;
          if (lastWinTs != null) {
            final d = lastWinTs.toDate().toUtc();
            lastWinDate = DateTime.utc(d.year, d.month, d.day);
          }
          if (lastWinDate == null) {
            currentWinStreak = 1;
          } else {
            final diff = todayWin.difference(lastWinDate).inDays;
            if (diff == 0) {
            } else if (diff == 1) {
              currentWinStreak += 1;
            } else {
              currentWinStreak = 1;
            }
          }
          if (currentWinStreak > bestWinStreak) {
            bestWinStreak = currentWinStreak;
          }
          lastWinTs = Timestamp.fromDate(nowUtc);
        }

        // Fastest win of all time
        final prevFastest = (existingOverview['fastestWinSeconds'] as num?)
            ?.toInt();
        int? fastestWinSeconds = prevFastest;
        if (win && seconds > 0) {
          if (fastestWinSeconds == null || seconds < fastestWinSeconds) {
            fastestWinSeconds = seconds;
          }
        }

        // Best (peak) global rating
        final prevBestGlobal =
            (existingOverview['bestGlobalRating'] as num?)?.toInt() ?? 0;
        int bestGlobalRating = prevBestGlobal;
        if (globalRating > bestGlobalRating) bestGlobalRating = globalRating;

        // Recent games list
        final existingRaw =
            (snap.data()?['recentGames'] as List<dynamic>? ?? []);
        final existingGames = existingRaw
            .whereType<Map<String, dynamic>>()
            .where((m) => m['level'] != null && m['win'] != null)
            .toList();
        final newEntry = {
          'level': level,
          'win': win,
          'seconds': seconds,
          'ts': Timestamp.now(),
        };
        final recentGames = [newEntry, ...existingGames];
        if (recentGames.length > 10) {
          recentGames.removeRange(10, recentGames.length);
        }

        final data = profile.toMap();
        data['overview'] = {
          'totalGames': totalGames,
          'totalWins': totalWins,
          'winPercent': totalWinPercent,
          'overallAvgSeconds': overallAvgSeconds,
          'avgSecondsEasy': profile.easy.averageSeconds,
          'avgSecondsMedium': profile.medium.averageSeconds,
          'avgSecondsHard': profile.hard.averageSeconds,
          'easyRating': profile.easy.rating,
          'mediumRating': profile.medium.rating,
          'hardRating': profile.hard.rating,
          'globalRating': globalRating,
          // activity streak
          'currentStreak': currentStreak,
          'bestStreak': bestStreak,
          'lastPlayTs': lastPlayTs,
          // win streak
          'currentWinStreak': currentWinStreak,
          'bestWinStreak': bestWinStreak,
          'lastWinTs': lastWinTs,
          // peaks & bests
          'bestGlobalRating': bestGlobalRating,
          'fastestWinSeconds': fastestWinSeconds,
          // bestRank maintained separately via updateBestRank
          'updatedAt': FieldValue.serverTimestamp(),
        };
        data['recentGames'] = recentGames;
        // ignore: avoid_print
        print(
          'updateStats write rating=$globalRating total=$totalGames wins=$totalWins level=$level win=$win',
        );
        txn.set(docRef, data, SetOptions(merge: true));

        // Return previous and new global rating to caller
        return {'old': prevGlobalRating, 'new': globalRating};
      });

      return result;
    } on FirebaseException catch (e, st) {
      if (e.code == 'permission-denied') {
        // ignore: avoid_print
        print(
          'Firestore permission denied for user stats update: ${e.message}',
        );
      } else {
        // ignore: avoid_print
        print(
          'FirebaseException in updateStats code=${e.code} message=${e.message}\n$st',
        );
        rethrow;
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('Unknown error in updateStats: $e\n$st');
      rethrow;
    }

    // Fallback (shouldn't reach here) to satisfy non-nullable return type
    return {'old': 0, 'new': 0};
  }

  Future<void> updateBestRank(String uid, int rank) async {
    if (rank <= 0) return;
    final docRef = _users.doc(uid);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(docRef);
      if (!snap.exists) return;
      final overview =
          (snap.data()?['overview'] as Map<String, dynamic>? ?? {});
      final existingBest = (overview['bestRank'] as num?)?.toInt();
      if (existingBest != null && existingBest <= rank) return; // not better
      txn.set(docRef, {
        'overview': {
          ...overview,
          'bestRank': rank,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    });
  }

  Stream<UserProfile> watchProfile(String uid) {
    return _users
        .doc(uid)
        .snapshots()
        .map((doc) => UserProfile.fromDoc(uid, doc));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserDoc(String uid) =>
      _users.doc(uid).snapshots();

  Stream<List<LeaderboardEntry>> leaderboardStream({int limit = 50}) {
    return _users
        .orderBy('overview.globalRating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => LeaderboardEntry.fromDoc(d.id, d.data()))
              .toList();
          // Client-side secondary sort by winPercent desc
          list.sort((a, b) {
            final ratingCmp = b.globalRating.compareTo(a.globalRating);
            if (ratingCmp != 0) return ratingCmp;
            return b.winPercent.compareTo(a.winPercent);
          });
          return list;
        });
  }

  Future<int> getUserRank(String uid) async {
    try {
      final userDoc = await _users.doc(uid).get();
      if (!userDoc.exists) return -1;
      final overview =
          userDoc.data()?['overview'] as Map<String, dynamic>? ?? {};
      final myRating = (overview['globalRating'] as num? ?? 0).toInt();
      final myWinPercent = (overview['winPercent'] as num? ?? 0).toDouble();

      // Count users with higher rating
      final higher = await _users
          .where('overview.globalRating', isGreaterThan: myRating)
          .count()
          .get();
      int higherCount = (higher.count ?? 0);

      // Fetch users with same rating (limited scope) and compare winPercent client-side.
      final sameRatingSnap = await _users
          .where('overview.globalRating', isEqualTo: myRating)
          .limit(200)
          .get();
      int betterWin = 0;
      for (final d in sameRatingSnap.docs) {
        if (d.id == uid) continue;
        final o = d.data()['overview'] as Map<String, dynamic>? ?? {};
        final wp = (o['winPercent'] as num? ?? 0).toDouble();
        if (wp > myWinPercent) betterWin++;
      }
      return higherCount + betterWin + 1;
    } catch (_) {
      return -1;
    }
  }

  Future<void> resetActivityStreakIfMissed(String uid) async {
    final docRef = _users.doc(uid);
    try {
      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(docRef);
        if (!snap.exists) return;
        final overview =
            (snap.data()?['overview'] as Map<String, dynamic>? ?? {});
        final currentStreak = (overview['currentStreak'] as num?)?.toInt() ?? 0;
        final lastPlayTs = overview['lastPlayTs'] as Timestamp?;
        if (currentStreak <= 0 || lastPlayTs == null) {
          return; // nothing to reset
        }
        final nowUtc = DateTime.now().toUtc();
        final today = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
        final lp = lastPlayTs.toDate().toUtc();
        final lastPlayDate = DateTime.utc(lp.year, lp.month, lp.day);
        final diff = today.difference(lastPlayDate).inDays;
        if (diff <= 1) return; // streak still valid or just today
        // Gap of 2+ days => reset currentStreak to 0 (keep bestStreak)
        txn.set(docRef, {
          'overview': {
            ...overview,
            'currentStreak': 0,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        }, SetOptions(merge: true));
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> setAvatarConsent(bool allow) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _users.doc(user.uid);
    final updates = <String, dynamic>{
      'allowAvatar': allow,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (allow) {
      final photo = user.photoURL;
      if (photo != null) updates['photoUrl'] = photo;
    } else {
      // Remove any previously stored photo
      updates['photoUrl'] = FieldValue.delete();
    }
    await docRef.set(updates, SetOptions(merge: true));
  }
}
