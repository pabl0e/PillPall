import 'package:flutter/material.dart';
import 'package:pillpall/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "Login to your account",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: <Widget>[
                        inputFile(label: "Email", obscur: true),
                        SizedBox(height: 10),
                        inputFile(label: "Password", obscur: true),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      // padding: EdgeInsets.only(top: 30, left: 3),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(50),
                      //   border: Border(
                      //     bottom: BorderSide(color: Colors.black),
                      //     top: BorderSide(color: Colors.black),
                      //     left: BorderSide(color: Colors.black),
                      //     right: BorderSide(color: Colors.black),
                      //   ),
                      // ),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () {},
                        color: Colors.pink[300],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // child: Container(
                  //   padding: EdgeInsets.only(top: 30, left: 3),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius,
                  //     circular(50),
                  //     border: Border(
                  //       bottom: BorderSide(color: Colors.black),
                  //       top: BorderSide(color: Colors.black),
                  //       left: BorderSide(color: Colors.black),
                  //       right: BorderSide(color: Colors.black),
                  //     ),
                  //   ),
                  // ),

                  // child: Container(
                  //   padding: EdgeInsets.only(top: 30, left: 3),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(50),
                  //     border: Border(
                  //       bottom: BorderSide(color: Colors.black),
                  //       top: BorderSide(color: Colors.black),
                  //       left: BorderSide(color: Colors.black),
                  //       right: BorderSide(color: Colors.black),
                  //     ),
                  //   ),
                  //   child: MaterialButton(
                  //     minWidth: double.infinity,
                  //     height: 60,
                  //     onPressed: () {},
                  //     color: Colors.pink[300],
                  //     elevation: 0,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(50),
                  //     ),
                  //     child: Text(
                  //       "Login",
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.w600,
                  //         color: Colors.white,
                  //         fontSize: 18,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  //   child: Container(padding: EdgeInsets.only(top: 30, left: 3),
                  //   decoration:   BoxDecoration(borderRadius: BorderRadius,circular(50),
                  //   border: Border(
                  //     bottom: BorderSide(color: Colors.black),
                  //     top: BorderSide(color: Colors.black),
                  //     left: BorderSide(color: Colors.black),
                  //     right: BorderSide(color: Colors.black),
                  //   ) )
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Create an account? ",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget inputFile({label, obscur = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 5),
      TextField(
        obscureText: obscur,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
        ),
      ),
      // SizedBox(height: 10),
    ],
  );
}
