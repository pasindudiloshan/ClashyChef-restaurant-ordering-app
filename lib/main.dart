import 'package:clashy_kitchen/provider.dart';
import 'package:clashy_kitchen/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/cart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDgmVuM3Hl4CEa4temwkDJ_W-satuQc0Ow",
          appId: "1:925890838008:web:3539f3990d5658f716ea0d",
          messagingSenderId: "925890838008",
          storageBucket: "clashy-kitchen.appspot.com",
          projectId: "clashy-kitchen"
      ),
    );
  } catch (e) {
    print('Error initializing Firebase: $e');

    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Cart()), // Cart provider
        ChangeNotifierProvider(create: (context) => UserProvider()), // User provider
      ],
      child: MaterialApp(
        title: 'Clashy Kitchen',
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
          splash: Image.asset(
            'assets/restaurant_logo.png',
            height: 600,
            scale: 2,
          ),
          splashTransition: SplashTransition.fadeTransition,
          duration: 2,
          nextScreen: SignUpPage(),
        ),
      ),
    );
  }
}
