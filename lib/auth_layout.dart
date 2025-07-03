import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/auth_service.dart';
import 'package:pillpall/login_page.dart';
import 'package:pillpall/widget/task_widget.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authServiceValue, child) {
        return StreamBuilder<User?>(
          stream: authServiceValue.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = const Center(
                key: ValueKey('loading'),
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              // User is authenticated
              widget = const Task_Widget(key: ValueKey('task_widget'));
            } else {
              // User is not authenticated or account was deleted
              widget = pageIfNotConnected != null
                  ? pageIfNotConnected!
                  : const LoginPage(key: ValueKey('login_page'));
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: widget,
            );
          },
        );
      },
    );
  }
}
