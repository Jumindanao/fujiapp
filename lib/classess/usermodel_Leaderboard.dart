class LeaderboardDetail {
  String name;
  String rank;
  int point;

  LeaderboardDetail({
    required this.name,
    required this.rank,
    required this.point,
  });

  // Factory constructor for Supabase data mapping
  factory LeaderboardDetail.fromMap(Map<String, dynamic> map, int rank) {
    return LeaderboardDetail(
      name: map['full_name'] ?? 'Unknown',
      rank: rank.toString(),
      point: map['points'] ?? 0,
    );
  }
}
