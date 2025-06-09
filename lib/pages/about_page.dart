import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:congress_app/widgets/CustomAppBar.dart';
import 'package:congress_app/widgets/AppDrawer.dart'; // <--- ADD THIS IMPORT
import 'package:congress_app/pages/search_page.dart'; // <--- ADD THIS IMPORT
import 'package:congress_app/pages/subscribe_page.dart';

class AboutPage extends StatelessWidget {

  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final formattedDateTime = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()); // Changed 'EEEE, MMMM d,YYYY' to 'EEEE, MMMM d, yyyy' for correct year formatting
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar( // Use your custom AppBar
        formattedDate: formattedDateTime, // Pass the formatted date
      ),
       // --- ADD THIS BLOCK HERE ---
      drawer: AppDrawer(
        currentRoute: 'About',
        onNavigate: (route) {
          Navigator.pop(context); // Always close the drawer first

          if (route == 'Home') {
            // If navigating to 'Home' (your FrontPage), pop all routes until the first one
            Navigator.popUntil(context, (r) => r.isFirst);
          } else if (route == 'Search') {
            // If navigating to 'Search' from 'AboutPage', push the MySearchPage
            // Make sure MySearchPage is imported: import 'package:congress_app/pages/search_page.dart';
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MySearchPage()));
          } else if (route == 'About') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
          } else if (route == 'Subscribe') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
          }
        },
      ),
      // --- END ADDED BLOCK ---
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: const TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -1.0,
                  ),
                ),
                Text(
                  'This is a satirical news app. All content is made up by Jerome Halligan.',
                  style: const TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                    letterSpacing: -.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
