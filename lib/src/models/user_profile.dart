import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl; // NEW
  final bool? allowAvatar; // NULL => not asked yet, true/false => user choice
  final PlayerStats easy;
  final PlayerStats medium;
  final PlayerStats hard;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.easy,
    required this.medium,
    required this.hard,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.allowAvatar,
  });

  factory UserProfile.initial(
    String uid,
    String? name,
    String? email, {
    String? photoUrl,
    bool? allowAvatar,
  }) {
    final now = DateTime.now();
    return UserProfile(
      uid: uid,
      displayName: name ?? 'Player',
      email: email ?? '',
      photoUrl: photoUrl,
      allowAvatar: allowAvatar, // null means not asked yet
      easy: PlayerStats.empty(),
      medium: PlayerStats.empty(),
      hard: PlayerStats.empty(),
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'email': email,
    if (photoUrl != null && allowAvatar == true) 'photoUrl': photoUrl,
    if (allowAvatar != null) 'allowAvatar': allowAvatar,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'easy': easy.toMap(),
    'medium': medium.toMap(),
    'hard': hard.toMap(),
  };

  factory UserProfile.fromDoc(
    String uid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return UserProfile(
      uid: uid,
      displayName: data['displayName'] as String? ?? 'Player',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? data['photoURL'] as String?,
      allowAvatar: data['allowAvatar'] as bool?,
      easy: PlayerStats.fromMap(
        data['easy'] as Map<String, dynamic>? ?? const {},
      ),
      medium: PlayerStats.fromMap(
        data['medium'] as Map<String, dynamic>? ?? const {},
      ),
      hard: PlayerStats.fromMap(
        data['hard'] as Map<String, dynamic>? ?? const {},
      ),
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  UserProfile copyWith({
    PlayerStats? easy,
    PlayerStats? medium,
    PlayerStats? hard,
    String? displayName,
    String? photoUrl,
    bool? allowAvatar,
  }) => UserProfile(
    uid: uid,
    displayName: displayName ?? this.displayName,
    email: email,
    photoUrl: photoUrl ?? this.photoUrl,
    allowAvatar: allowAvatar ?? this.allowAvatar,
    easy: easy ?? this.easy,
    medium: medium ?? this.medium,
    hard: hard ?? this.hard,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}

class PlayerStats {
  final int gamesPlayed;
  final int wins;
  final int totalSeconds;
  final int rating;

  const PlayerStats({
    required this.gamesPlayed,
    required this.wins,
    required this.totalSeconds,
    required this.rating,
  });

  double get winPercent => gamesPlayed == 0 ? 0 : wins / gamesPlayed;
  double get averageSeconds => wins == 0 ? 0 : totalSeconds / wins;

  factory PlayerStats.empty() =>
      const PlayerStats(gamesPlayed: 0, wins: 0, totalSeconds: 0, rating: 100);

  PlayerStats recordGame({
    required bool win,
    required int seconds,
    int ratingDelta = 0,
  }) => PlayerStats(
    gamesPlayed: gamesPlayed + 1,
    wins: wins + (win ? 1 : 0),
    totalSeconds: win ? totalSeconds + seconds : totalSeconds,
    rating: rating + ratingDelta,
  );

  Map<String, dynamic> toMap() => {
    'gamesPlayed': gamesPlayed,
    'wins': wins,
    'totalSeconds': totalSeconds,
    'rating': rating,
  };

  factory PlayerStats.fromMap(Map<String, dynamic> data) => PlayerStats(
    gamesPlayed: (data['gamesPlayed'] as num?)?.toInt() ?? 0,
    wins: (data['wins'] as num?)?.toInt() ?? 0,
    totalSeconds: (data['totalSeconds'] as num?)?.toInt() ?? 0,
    rating: (data['rating'] as num?)?.toInt() ?? 100,
  );
}
