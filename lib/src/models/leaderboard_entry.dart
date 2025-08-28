class LeaderboardEntry {
  final String uid;
  final String? displayName;
  final String? email;
  final int globalRating;
  final int easyRating;
  final int mediumRating;
  final int hardRating;
  final int totalGames;
  final int totalWins;
  final double winPercent; // 0..1 fraction
  final String? photoUrl; // NEW

  LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.globalRating,
    required this.easyRating,
    required this.mediumRating,
    required this.hardRating,
    required this.totalGames,
    required this.totalWins,
    required this.winPercent,
    this.photoUrl,
  });

  factory LeaderboardEntry.fromDoc(String uid, Map<String, dynamic> data) {
    final overview = (data['overview'] as Map<String, dynamic>? ?? {});
    return LeaderboardEntry(
      uid: uid,
      displayName: data['displayName'] as String?,
      email: data['email'] as String?,
      globalRating: (overview['globalRating'] as num? ?? 0).toInt(),
      easyRating: (overview['easyRating'] as num? ?? 0).toInt(),
      mediumRating: (overview['mediumRating'] as num? ?? 0).toInt(),
      hardRating: (overview['hardRating'] as num? ?? 0).toInt(),
      totalGames: (overview['totalGames'] as num? ?? 0).toInt(),
      totalWins: (overview['totalWins'] as num? ?? 0).toInt(),
      winPercent: (overview['winPercent'] as num? ?? 0).toDouble(),
      photoUrl: data['photoUrl'] as String? ?? data['photoURL'] as String?,
    );
  }
}
