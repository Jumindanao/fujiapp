class LeaderboardDetail {
  String image;
  String name;
  String rank;
  int point;

  LeaderboardDetail({
    required this.image,
    required this.name,
    required this.rank,
    required this.point,
  });
}

List<LeaderboardDetail> userItems = [
  LeaderboardDetail(
    image: "",
    name: 'Dora Hines',
    rank: "4 ",
    point: 6432,
  ),
  LeaderboardDetail(
    image: "",
    name: 'Alise Smith',
    rank: "5 ",
    point: 5232,
  ),
  LeaderboardDetail(
    image: "",
    name: 'Boss Dee',
    rank: "6 ",
    point: 5200,
  ),
  LeaderboardDetail(
    image: "",
    name: 'Gender Tie',
    rank: "7 ",
    point: 4900,
  ),
  LeaderboardDetail(
    image: "",
    name: 'Roma Roy',
    rank: "8 ",
    point: 4100,
  ),
  LeaderboardDetail(
    image: "",
    name: 'Alta Koch',
    rank: "43",
    point: 2200,
  ),
];
