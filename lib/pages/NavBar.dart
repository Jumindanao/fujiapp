import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NavBar extends StatefulWidget {
  final Readdata userData;

  const NavBar({super.key, required this.userData});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    String userid = Supabase.instance.client.auth.currentUser!.id;

    final getpicresponse = await Supabase.instance.client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userid)
        .single();

    if (getpicresponse.isNotEmpty) {
      setState(() {
        _profileImageUrl = getpicresponse['avatar_url'];
      });
    }
  }

  void _showPopupMenu(BuildContext context, Offset offset) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.email),
            title: Text(widget.userData.theemail),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                '/Userprofileview',
                arguments: Readdata(
                  id: widget.userData.id,
                  theusername: widget.userData.theusername,
                  theemail: widget.userData.theemail,
                  therole: widget.userData.therole,
                  isPrivacy: widget.userData.isPrivacy,
                ),
              );
            },
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text(
                'Fuji: Japanese Learning',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: Colors.black,
                  fontSize: 22,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.asset(
                    'assets/fujiLogo.png', // Default image
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
              decoration: const BoxDecoration(color: Colors.white),
              accountEmail: null,
            ),
            _buildNavButton(
              title: 'Learn',
              icon: FontAwesomeIcons.house,
              iconColor: Colors.pink,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  '/CoursePage',
                  arguments: widget.userData,
                );
              },
            ),
            _buildNavButton(
              title: 'Text Recognition',
              icon: Icons.camera_outlined,
              iconColor: const Color.fromARGB(255, 169, 120, 5),
              isSelected: false,
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  '/TextRecognition',
                  arguments: widget.userData,
                );
              },
            ),
            _buildNavButton(
              title: 'Dictionary',
              icon: FontAwesomeIcons.book,
              iconColor: Colors.grey,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  '/Dictionary',
                  arguments: widget.userData,
                );
              },
            ),
            _buildNavButton(
              title: 'SpeechToText',
              icon: FontAwesomeIcons.chartBar,
              iconColor: Colors.grey,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  '/SpeechtoTextRecognition',
                  arguments: widget.userData,
                );
              },
            ),
            _buildNavButton(
              title: 'Leaderboards',
              icon: FontAwesomeIcons.medal,
              iconColor: Colors.amber,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  '/Leaderboardpage',
                  arguments: widget.userData,
                );
              },
            ),
            const SizedBox(height: 16), // Add space before bottom header
            UserAccountsDrawerHeader(
              accountName: Text(
                widget.userData.theusername,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  color: Colors.black,
                  fontSize: 22,
                ),
              ),
              currentAccountPicture: GestureDetector(
                onTapDown: (TapDownDetails details) {
                  _showPopupMenu(context, details.globalPosition);
                },
                child: CircleAvatar(
                  child: ClipOval(
                    child: _profileImageUrl.isNotEmpty
                        ? Image.network(
                            _profileImageUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/cherryBlossomDefaultProfile.jfif', // Default image
                            width: 90,
                            height: 90,
                          ),
                  ),
                ),
              ),
              decoration: const BoxDecoration(color: Colors.white),
              accountEmail: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            leading: Icon(icon, color: iconColor),
            title: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
