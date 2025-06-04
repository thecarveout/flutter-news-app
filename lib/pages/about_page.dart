import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:congress_app/widgets/CustomAppBar.dart';

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
                  style: GoogleFonts.merriweather(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -1.0,
                  ),
                ),
                Text(
                  'This is a satirical news app. All content is made up by Jerome Halligan.',
                  style: GoogleFonts.merriweather(
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
