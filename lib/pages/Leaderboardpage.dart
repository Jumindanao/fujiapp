import 'package:flutter/material.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'package:fuji_app/classess/usermodel_Leaderboard.dart';
import 'package:fuji_app/pages/NavBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Leaderboardpage extends StatefulWidget {
  const Leaderboardpage({super.key});

  @override
  State<Leaderboardpage> createState() => _LeaderboardpageState();
}

class _LeaderboardpageState extends State<Leaderboardpage> {
  List<LeaderboardDetail> userItems = [];
  @override
  void initState() {
    super.initState();
    fetchLeaderboardData();
  }

  Future<void> fetchLeaderboardData() async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('full_name, points')
        .order('points', ascending: false)
        .limit(10);

    if (response.isNotEmpty) {
      // Map Supabase data to our model
      final data = response as List<dynamic>;
      setState(() {
        userItems = data
            .asMap()
            .entries
            .map((entry) =>
                LeaderboardDetail.fromMap(entry.value, entry.key + 1))
            .toList();
      });
    } else {
      print("Error fetching leaderboard data: $response");
    }
  }

  Widget build(BuildContext context) {
    final Readdata userData =
        ModalRoute.of(context)!.settings.arguments as Readdata;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC1C6FC),
      ),
      drawer: NavBar(userData: userData),
      body: Stack(
        children: [
          // Background Image and Line
          Column(
            children: [
              Image.asset(
                "assets/leaderboard3.png",
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ],
          ),
          // Centered FUJI Leaderboard text
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 70),
              child: Column(
                children: [
                  Text(
                    "Fuji Leaderboard",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Top 3 Rankings",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Dynamic rank display for top 3 users
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Rank 2
                  if (userItems.length > 1)
                    rank(
                      radius: 30.0,
                      height: 10,
                      name: userItems[1].name,
                      point: userItems[1].point.toString(),
                    ),

                  // Rank 1
                  if (userItems.isNotEmpty)
                    rank(
                      radius: 40.0,
                      height: 25,
                      name: userItems[0].name,
                      point: userItems[0].point.toString(),
                    ),
                  // Rank 3
                  if (userItems.length > 2)
                    rank(
                      radius: 30.0,
                      height: 10,
                      name: userItems[2].name,
                      point: userItems[2].point.toString(),
                    ),
                ],
              ),
            ),
          ),
          // Bottom part: User list
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 1.9,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: userItems.length,
                itemBuilder: (context, index) {
                  final items = userItems[index];
                  return Padding(
                    padding:
                        const EdgeInsets.only(right: 20, left: 20, bottom: 15),
                    child: Row(
                      children: [
                        Text(
                          items.rank,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 15),
                        CircleAvatar(
                          radius: 25,
                          // backgroundImage: AssetImage(items.image),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          items.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 25,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 5),
                              const RotatedBox(
                                quarterTurns: 1,
                                child: Icon(
                                  Icons.back_hand,
                                  color: Color.fromARGB(255, 255, 187, 0),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                items.point.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column rank({
    required double radius,
    required double height,
    required String name,
    required String point,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          // backgroundImage: AssetImage(image),
        ),
        SizedBox(height: height),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: height),
        Container(
          height: 25,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              const SizedBox(width: 5),
              const Icon(
                Icons.back_hand,
                color: Color.fromARGB(255, 255, 187, 0),
              ),
              const SizedBox(width: 5),
              Text(
                point,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
