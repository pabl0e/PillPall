import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pillpall/auth_layout.dart';
import 'package:pillpall/login_page.dart';
import 'package:pillpall/signup_page.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PillPall',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFFFDDED),
          brightness: Brightness.light,
        ),
      ),
      home: const AuthLayout(
        pageIfNotConnected: MyHomePage(
          title: 'Welcome to PillPall!',
          key: ValueKey('welcome_page'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "PillPall is a medication management app designed to help users keep track of their medications, set reminders, and manage their health effectively. PillPall is here to support you in your health journey.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      // Then try the asset
                      SvgPicture.asset('assets/pill.svg'),
                    ],
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      print('Login button pressed - Starting navigation');
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                        print('Navigation completed successfully');
                      } catch (e) {
                        print('Navigation error: $e');
                      }
                    },
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      print('Sign Up button pressed - Starting navigation');
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                        print('Navigation completed successfully');
                      } catch (e) {
                        print('Navigation error: $e');
                      }
                    },
                    color: Colors.pink[200],
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.pink[200]!),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
