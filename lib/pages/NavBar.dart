import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NavBar extends StatelessWidget {
  final Readdata userData;

  const NavBar({super.key, required this.userData});

  void _showPopupMenu(BuildContext context, Offset offset) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.email),
            title: Text(userData.theemail),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                '/Userprofileview',
                arguments: Readdata(
                  id: userData.id,
                  theusername: userData.theusername,
                  theemail: userData.theemail,
                  therole: userData.therole,
                  isPrivacy: userData.isPrivacy,
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
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(
              'Fuji',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Colors.black,
                fontSize: 22,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://picsum.photos/seed/921/600',
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
            icon: Icons.house,
            iconColor: const Color.fromARGB(255, 169, 120, 5),
            isSelected: false,
            onTap: () {},
          ),
          _buildNavButton(
            title: 'Leaderboards',
            icon: FontAwesomeIcons.medal,
            iconColor: Colors.amber,
            isSelected: false,
            onTap: () {},
          ),
          _buildNavButton(
            title: 'Settings',
            icon: FontAwesomeIcons.gear,
            iconColor: Colors.grey,
            isSelected: false,
            onTap: () {},
          ),
          const Spacer(),
          UserAccountsDrawerHeader(
            accountName: Text(
              userData.theusername,
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
                  child: Image.network(
                    'https://picsum.photos/seed/921/600',
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
