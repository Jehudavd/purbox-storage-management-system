import 'package:flutter/material.dart';

class SidebarMenu extends StatelessWidget {
  final String token;
  SidebarMenu({required this.token});

  void _signOut(BuildContext context) {
    // Perform sign out logic, e.g., clear token, navigate to login page
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Purbox',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _createDrawerItem(
            icon: Icons.home_outlined,
            text: 'Home',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home', arguments: token);
            },
          ),
          _createDrawerItem(
            icon: Icons.category_outlined,
            text: 'Categories',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/categories', arguments: token);
            },
          ),
          Divider(),
          _createDrawerItem(
            icon: Icons.exit_to_app_outlined,
            text: 'Sign Out',
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem(
      {required IconData icon, required String text, required GestureTapCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        text,
        style: TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
