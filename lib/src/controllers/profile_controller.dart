import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

class ProfileController extends ChangeNotifier {
  final UserRepository _repo;
  UserProfile? profile;
  bool loading = false;
  StreamSubscription? _sub;
  Map<String, dynamic>? overview; // aggregated fields
  ProfileController(this._repo);

  int? _rank; // cached global rank
  bool _rankLoading = false;
  Timer? _rankDebounce; // debounce rapid doc updates

  int? get rank => _rank;

  Future<void> load() async {
    if (loading) return;
    loading = true;
    notifyListeners();
    try {
      final p = await _repo.getOrCreateCurrentUser();
      if (p == null) {
        return; // will retry when auth user becomes available
      }
      profile = p;
      // If consent not yet given, leave it for sign-in screen (already handled) or future settings screen.
      _listen();
      // Immediately schedule an initial rank fetch instead of waiting for first doc listener tick.
      _scheduleRankUpdate();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _listen() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _sub?.cancel();
    _sub = _repo
        .watchUserDoc(uid)
        .listen(
          (snap) {
            profile = UserProfile.fromDoc(uid, snap);
            final data = snap.data();
            overview = (data?['overview'] as Map<String, dynamic>?) ?? {};
            recentGames = (data?['recentGames'] as List<dynamic>? ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();
            notifyListeners();
            _scheduleRankUpdate();
          },
          onError: (e) {
            // If signed out, ignore permission errors (listener will be reset on reset()).
            if (FirebaseAuth.instance.currentUser == null) return;
            if (kDebugMode) {
              // Optional: log other errors
              // print('Profile listener error: $e');
            }
          },
        );
  }

  void _scheduleRankUpdate() {
    _rankDebounce?.cancel();
    _rankDebounce = Timer(const Duration(milliseconds: 250), () {
      _updateRank();
    });
  }

  Future<void> _updateRank() async {
    if (_rankLoading) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _rankLoading = true;
    try {
      final newRank = await _repo.getUserRank(uid);
      if (newRank >= 1) {
        // Valid rank
        if (newRank != _rank) {
          _rank = newRank;
          _repo.updateBestRank(uid, _rank!);
          notifyListeners();
        }
      } else {
        // -1 means temporary failure; do NOT clear a known rank. Retry soon if we don't have one yet.
        if (_rank == null) {
          Future.delayed(const Duration(seconds: 2), () {
            _scheduleRankUpdate();
          });
        }
      }
    } finally {
      _rankLoading = false;
    }
  }

  List<Map<String, dynamic>> recentGames = [];

  int get globalRating {
    if (overview != null && overview!['globalRating'] is num) {
      return (overview!['globalRating'] as num).toInt();
    }
    if (profile == null) return 0;
    return profile!.easy.rating + profile!.medium.rating + profile!.hard.rating;
  }

  Map<String, dynamic>? get overviewData => overview;

  int? get currentStreak {
    final v = overview?['currentStreak'];
    if (v is num) return v.toInt();
    return null;
  }

  int? get bestStreak {
    final v = overview?['bestStreak'];
    if (v is num) return v.toInt();
    return null;
  }

  int? get fastestWinSeconds {
    final v = overview?['fastestWinSeconds'];
    if (v is num) return v.toInt();
    return null;
  }

  int? get bestGlobalRating {
    final v = overview?['bestGlobalRating'];
    if (v is num) return v.toInt();
    return null;
  }

  int? get bestRank {
    final v = overview?['bestRank'];
    if (v is num) return v.toInt();
    return null;
  }

  int? get currentWinStreak {
    final v = overview?['currentWinStreak'];
    if (v is num) return v.toInt();
    return null;
  }

  int? get bestWinStreak {
    final v = overview?['bestWinStreak'];
    if (v is num) return v.toInt();
    return null;
  }

  Future<Map<String, int>> recordGame({
    required String level,
    required bool win,
    required int seconds,
    int ratingDelta = 0,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Use repository return to get accurate ratings immediately
    final result = await _repo.updateStats(
      uid: uid,
      level: level,
      win: win,
      seconds: seconds,
      ratingDelta: ratingDelta,
    );

    // Update local overview will arrive via listener; return repository result for immediate feedback
    return {
      'old': result['old'] ?? 0,
      'new': result['new'] ?? 0,
      'delta': (result['new'] ?? 0) - (result['old'] ?? 0),
    };
  }

  Future<void> updateAvatarConsent(bool allow) async {
    await _repo.setAvatarConsent(allow);
    await load();
  }

  void reset() {
    _sub?.cancel();
    _sub = null;
    profile = null;
    overview = null;
    recentGames = [];
    _rank = null;
    _rankDebounce?.cancel();
    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _rankDebounce?.cancel();
    super.dispose();
  }
}
