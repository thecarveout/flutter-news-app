import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const AppDrawer({
    Key? key,
    required this.currentRoute,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // You might want a custom DrawerHeader here for a logo or title
          Center(
            child: SizedBox(
              height: 120, // Match your AppBar height
              child: DrawerHeader(
                padding: EdgeInsetsGeometry.only(top:48),
                decoration: const BoxDecoration(color: Colors.black),
                child:
                  Text('The Carveout',
                    style: GoogleFonts.bebasNeue(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                letterSpacing: -1,
                                color: Colors.white),),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            selected: currentRoute == 'Home',
            onTap: () => onNavigate('Home'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text('About', style: TextStyle(color: Colors.white)),
            selected: currentRoute == 'About',
            onTap: () => onNavigate('About'),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline, color: Colors.white),
            title: const Text('Subscribe', style: TextStyle(color: Colors.white)),
            selected: currentRoute == 'Subscribe',
            onTap: () => onNavigate('Subscribe'),
          ),
          // Add more list tiles as needed
        ],
      ),
    );
  }
}