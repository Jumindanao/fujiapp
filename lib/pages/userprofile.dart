import 'package:flutter/material.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'package:fuji_app/main.dart';
import 'package:fuji_app/pages/NavBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  String _imageUrl = '';
  String userid = supabase.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    getpicture();
  }

  Future<void> getpicture() async {
    final getpicresponse = await Supabase.instance.client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userid)
        .single(); // Ensure only one record is retrieved

    if (getpicresponse.isNotEmpty) {
      setState(() {
        _imageUrl = getpicresponse['avatar_url'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _namecontroller = TextEditingController();
    final TextEditingController _emailcontroller = TextEditingController();

    //parasa navbar ug other need information
    final Readdata userData =
        ModalRoute.of(context)!.settings.arguments as Readdata;

    _namecontroller.text = userData.theusername;
    _emailcontroller.text = userData.theemail;
    print(_imageUrl);
    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: NavBar(
        userData: userData,
      ),
      appBar: AppBar(),
      body: Column(
        children: [
          // Profile Picture Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Circular Profile Picture
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageUrl.isNotEmpty
                      ? NetworkImage(_imageUrl) // Use fetched image URL
                      : const AssetImage(
                              'assets/cherryBlossomDefaultProfile.jfif')
                          as ImageProvider, // Placeholder image
                ),
                // Edit Icon Overlaid
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.of(context).pushNamed(
                      '/EditProfilePage',
                      arguments: userData,
                    );

                    // Update image if new URL returned from EditProfilePage
                    if (result != null && result is String) {
                      setState(() {
                        _imageUrl = result;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // User Info
          Text(
            _namecontroller.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _emailcontroller.text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          // Upgrade to Pro Button

          const SizedBox(height: 24),

          // Stats Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatsItem(title: '4.8', subtitle: 'Ranking'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16),
          //   child: Align(
          //     alignment: Alignment.centerLeft,
          //     child: Text(
          //       'About',
          //       style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: Text(
          //     'Certified Personal Trainer and Nutritionist with years of experience in creating effective diets and training plans focused on achieving individual customers\' goals in a smooth way.',
          //     style: TextStyle(
          //       color: Colors.grey,
          //       fontSize: 14,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// Stats item widget for ranking, following, followers
class _StatsItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatsItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// // Edit Profile Page
// class EditProfilePage extends StatelessWidget {
//   const EditProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//       ),
//       body: const Center(
//         child: Text('Edit Profile Page'),
//       ),
//     );
//   }
// }
