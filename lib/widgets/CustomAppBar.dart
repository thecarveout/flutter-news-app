import 'package:congress_app/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A custom AppBar widget featuring a large logo image as the primary title,
/// with a formatted date displayed directly beneath it.
/// The content is constrained to a maximum width for larger screens.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String formattedDate;
  final double preferredHeight; // New: To control the height of the AppBar

  /// Creates a [CustomAppBar].
  ///
  /// The [logoUrl] is the URL to your logo image. It's optional.
  /// The [formattedDate] is a string representing the current date or a relevant date.
  /// [preferredHeight] defines the total height of this custom AppBar.
  const CustomAppBar({
    Key? key,
    required this.formattedDate,
    this.preferredHeight = 70.0, // Default height for a large logo and date
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight); // Use the specified height

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0, // No shadow for a flat design
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Menu icon for drawer
          onPressed: () {
            if (Scaffold.of(context).hasDrawer) {
              Scaffold.of(context).openDrawer();
            } else {
              print('Warning: No drawer found for this Scaffold.');
            }
          },
          tooltip: null,
        ),
      ),

      title: Center( // Center the entire content block horizontally
        child: Container(
          // Constrain the content to a max width, as before
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column( // <--- Changed from Row to Column for vertical layout
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically within the column
            crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally within the column
            mainAxisSize: MainAxisSize.min, // Make column only take up needed vertical space
            children: [
              Text('The Carveout',
                style: const TextStyle(
                              fontFamily: 'Bebas Neue',
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              letterSpacing: -1,
                              color: Colors.black,
                              ),
                ),

              // Formatted Date Text
              Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,  
                ),
              ),
            ],
          ),
        ),
      ),
      shape: Border(
        bottom: BorderSide(
          color: Colors.grey,
          width:1,
        ),
      ),
      actions: [
        // Navigate to the Search Screen
    const SizedBox(width: 8),
    IconButton(
      icon: const Icon(Icons.search, color: Colors.black),
        onPressed: () {
        // This is how you navigate to your new Algolia-powered search page (MySearchPage)
        // using standard Flutter navigation.
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MySearchPage(), // Instantiate your new MySearchPage widget here
        ),
        );
      },
      tooltip: null,
    ),
    ],
  );
  }
}