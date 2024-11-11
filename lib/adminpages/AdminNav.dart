import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminNav extends StatefulWidget {
  const AdminNav({super.key});

  @override
  State<AdminNav> createState() => _AdminNavState();
}

class _AdminNavState extends State<AdminNav> {
  String _selectedButton = '';

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
      child: ListView(
        // Use ListView for scrollability
        children: [
          // Admin Header Section
          UserAccountsDrawerHeader(
            accountName: const Text(
              'Fuji Admin',
              style: TextStyle(
                color: Colors.black,
                fontSize: 35,
                fontFamily: 'Cursive',
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
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

          // Dynamic Navigation Buttons
          _buildNavButton(
            title: 'Courses',
            icon: Icons.school,
            iconColor: Colors.blueAccent,
            isSelected: _selectedButton == 'Courses',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/AdminCourse',
                  arguments: userData);
            },
          ),

          _buildNavButton(
            title: 'Units',
            icon: Icons.layers,
            iconColor: Colors.green,
            isSelected: _selectedButton == 'Units',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/AdminUnitPage',
                  arguments: userData);
            },
          ),

          _buildNavButton(
            title: 'Lessons',
            icon: Icons.library_books,
            iconColor: Colors.purpleAccent,
            isSelected: _selectedButton == 'Lessons',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/AdminLessonPage',
                  arguments: userData);
            },
          ),

          _buildNavButton(
            title: 'Challenges',
            icon: Icons.flag,
            iconColor: Colors.redAccent,
            isSelected: _selectedButton == 'Challenges',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/AdminChallengesPage',
                  arguments: userData);
            },
          ),

          _buildNavButton(
            title: 'Challenge Options',
            icon: Icons.check_circle_outline,
            iconColor: Colors.orange,
            isSelected: _selectedButton == 'Challenge Options',
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, '/AdminChallengeOptionPage',
                  arguments: userData);
            },
          ),

          // User profile section at the bottom
          UserAccountsDrawerHeader(
            accountName: const Text(
              'Yozakura',
              style: TextStyle(
                color: Colors.black,
                fontSize: 35,
                fontFamily: 'Cursive',
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            currentAccountPicture: GestureDetector(
              onTapDown: (TapDownDetails details) {
                _showPopupMenu(context, details.globalPosition);
              },
              child: CircleAvatar(
                child: ClipOval(
                  child: Image.asset(
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
