import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Keep this for debugProfileBuildsEnabled
import 'package:firebase_core/firebase_core.dart';
// import 'pages/front_page.dart'; // No longer directly used as home
import 'firebase_options.dart';
import 'splash_screen.dart'; // <--- IMPORT YOUR SPLASH SCREEN HERE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // These are for performance profiling. You can keep them during development
  // but usually remove them for production release builds.
  debugProfileBuildsEnabled = true;
  debugProfileBuildsEnabledUserWidgets = true;

  runApp(const MyApp()); // Added const to MyApp as it's stateless
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Added const constructor for MyApp

  @override
  Widget build(BuildContext context) {
    return TooltipTheme( // <--- Keep your TooltipTheme
      data: TooltipThemeData(
        waitDuration: Duration.zero,  // Tooltip appears instantly
        showDuration: Duration.zero,  // Tooltip disappears instantly
        // You can also try making it transparent to ensure nothing is drawn
        // decoration: BoxDecoration(color: Colors.transparent),
        // textStyle: TextStyle(color: Colors.transparent),
      ),
      child: MaterialApp(
        title: 'The Carveout',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(), // <--- SET YOUR SPLASH SCREEN AS HOME
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}