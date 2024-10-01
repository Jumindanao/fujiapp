import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "package:fuji_app/classess/readdata.dart";
import 'package:supabase_flutter/supabase_flutter.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  // Manage the currently selected button
  String _selectedButton =
      ''; // Empty initially, will be 'Learn', 'Leaderboards', or 'Settings'

  void _showPopupMenu(BuildContext context, Offset offset) {
    final Readdata userData =
        ModalRoute.of(context)!.settings.arguments as Readdata;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.email),
            title: Text(userData.theemail),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/Userprofileview',
                  arguments: Readdata(
                      id: userData.id,
                      theusername: userData.theusername,
                      theemail: userData.theemail,
                      therole: userData.therole));
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
              Navigator.of(context).pushReplacementNamed(
                '/login',
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Readdata userData =
        ModalRoute.of(context)!.settings.arguments as Readdata;
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
                letterSpacing: 0.0,
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

          // Learn Button with Curved Border and Tap/Touch Effect
          _buildNavButton(
            title: 'Learn',
            icon: Icons.house,
            iconColor: const Color.fromARGB(255, 169, 120, 5),
            isSelected: _selectedButton == 'Learn',
            onTap: () {
              setState(() {
                _selectedButton = 'Learn';
              });
            },
          ),

          // Leaderboards Button with Curved Border and Tap/Touch Effect
          _buildNavButton(
            title: 'Leaderboards',
            icon: FontAwesomeIcons.medal,
            iconColor: Colors.amber,
            isSelected: _selectedButton == 'Leaderboards',
            onTap: () {
              setState(() {
                _selectedButton = 'Leaderboards';
              });
            },
          ),

          // Settings Button with Curved Border and Tap/Touch Effect
          _buildNavButton(
            title: 'Settings',
            icon: FontAwesomeIcons.gear,
            iconColor: Colors.grey,
            isSelected: _selectedButton == 'Settings',
            onTap: () {
              setState(() {
                _selectedButton = 'Settings';
              });
            },
          ),

          const Spacer(), // Pushes the bottom UserAccountsDrawerHeader down

          // User profile section
          UserAccountsDrawerHeader(
            accountName: Text(
              userData.theusername,
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.black,
                fontSize: 22,
                letterSpacing: 0.0,
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

  // A method to create buttons dynamically
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
            color: isSelected
                ? Colors.green
                : Colors.transparent, // Show green border if selected
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12), // Curved Edges
        ),
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            leading: Icon(
              icon,
              color: iconColor,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.blue
                    : Colors.green, // Change text color if selected
              ),
            ),
          ),
        ),
      ),
    );
  }
}
