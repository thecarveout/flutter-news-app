import 'package:flutter/material.dart';
import 'package:congress_app/pages/front_page.dart'; // Make sure this path is correct
// import 'package:algolia_helper_flutter/algolia_helper_flutter.dart'; // Uncomment if initializing here

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadAppDependencies();
  }

  Future<void> _loadAppDependencies() async {
    // --- THIS IS WHERE YOU PUT YOUR ASYNCHRONOUS INITIALIZATION ---
    // Instead of Future.delayed, you'd put your actual async work here.

    // Example: Initialize Algolia here instead of in MySearchPage's initState
    // You would pass the initialized searcher down or use a service locator.
    // Example (conceptual):
    // await AlgoliaService.initialize(); // Assuming you have an Algolia service

    // Simulate some loading time for demonstration
    await Future.delayed(const Duration(seconds: 5)); // Adjust as needed

    // --- END ASYNCHRONOUS INITIALIZATION ---

    // After loading, navigate to your main page
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FrontPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // White background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Your Logo Image ---
            // If you have an image asset, make sure it's declared in pubspec.yaml
            // Example: assets/images/my_logo.png
            // Image.asset(
            //   'assets/images/my_logo.png', // Replace with your logo path
            //   width: 200, // Adjust size as needed
            //   height: 200,
            // ),
            //
            // SizedBox(height: 20), // Spacing between logo and text

            // --- Your App Name Text ---
            Text(
              'The Carveout', // Replace with your app name
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                fontSize: 36,
                fontWeight: FontWeight.w400,
                color: Colors.black, // Adjust color as needed
              ),
            ),
            SizedBox(height: 40), // Spacing
            CircularProgressIndicator(color: Colors.black,), // Optional loading indicator
          ],
        ),
      ),
    );
  }
}