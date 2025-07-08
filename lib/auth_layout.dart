import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/auth_service.dart';
import 'package:pillpall/services/alarm_service.dart';
import 'package:pillpall/login_page.dart';
import 'package:pillpall/widget/task_widget.dart';

class AuthLayout extends StatefulWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> with WidgetsBindingObserver {
  bool _alarmServiceInitialized = false;
  User? _currentUser;
  String? _lastInitializedUserId; // Track which user we initialized for

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Only dispose alarm service when the widget is actually being destroyed
    _disposeAlarmServiceIfNeeded();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Don't dispose alarm service when app goes to background
    if (state == AppLifecycleState.paused) {
      print('📱 App paused - keeping AlarmService running');
    } else if (state == AppLifecycleState.resumed) {
      print('📱 App resumed - ensuring AlarmService is running');
      if (_currentUser != null && !_alarmServiceInitialized) {
        _initializeAlarmServiceIfNeeded();
      }
    }
  }

  void _initializeAlarmServiceIfNeeded() {
    // Enhanced validation - only initialize if user is authenticated
    if (!mounted || _currentUser == null) {
      print('⚠️ Cannot initialize AlarmService: ${!mounted ? 'Widget not mounted' : 'No authenticated user'}');
      return;
    }

    final userId = _currentUser!.uid;
    
    // Don't reinitialize for the same user
    if (_alarmServiceInitialized && _lastInitializedUserId == userId) {
      print('ℹ️ AlarmService already initialized for user: $userId');
      return;
    }

    // If we're switching users, dispose the old service first
    if (_alarmServiceInitialized && _lastInitializedUserId != userId) {
      print('🔄 Switching users - disposing old AlarmService');
      _disposeAlarmServiceIfNeeded();
    }

    print('🚀 Preparing to initialize AlarmService for authenticated user: $userId');

    // Use PostFrameCallback to ensure widget tree is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Double-check everything is still valid after the frame
      if (mounted && _currentUser != null && _currentUser!.uid == userId) {
        try {
          print('🔧 Initializing AlarmService...');
          AlarmService().initialize(context);
          
          if (mounted) {
            setState(() {
              _alarmServiceInitialized = true;
              _lastInitializedUserId = userId;
            });
          }
          print('✅ AlarmService initialized successfully for user: $userId');
        } catch (e) {
          print('❌ Error initializing AlarmService: $e');
          // Reset state on error
          if (mounted) {
            setState(() {
              _alarmServiceInitialized = false;
              _lastInitializedUserId = null;
            });
          }
        }
      } else {
        print('⚠️ Context changed during initialization - skipping AlarmService setup');
      }
    });
  }

  void _disposeAlarmServiceIfNeeded() {
    if (_alarmServiceInitialized) {
      try {
        print('🛑 Disposing AlarmService for user: $_lastInitializedUserId');
        AlarmService().dispose();
        _alarmServiceInitialized = false;
        _lastInitializedUserId = null;
        print('✅ AlarmService disposed successfully');
      } catch (e) {
        print('❌ Error disposing AlarmService: $e');
        // Force reset state even on error
        _alarmServiceInitialized = false;
        _lastInitializedUserId = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authServiceValue, child) {
        return StreamBuilder<User?>(
          stream: authServiceValue.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            
            // Track current user state
            final newUser = snapshot.data;
            final userChanged = _currentUser?.uid != newUser?.uid;
            
            // Show loading while waiting for auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('⏳ Waiting for authentication state...');
              widget = const Scaffold(
                body: Center(
                  key: ValueKey('auth_loading'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading...'),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              // User is authenticated
              final previousUser = _currentUser;
              _currentUser = snapshot.data;
              
              // Log user authentication
              if (userChanged) {
                print('👤 User authenticated: ${_currentUser!.uid}');
                if (previousUser != null) {
                  print('🔄 User changed from ${previousUser.uid} to ${_currentUser!.uid}');
                }
              }
              
              // Only initialize if user actually changed or service not initialized
              if (userChanged || !_alarmServiceInitialized) {
                _initializeAlarmServiceIfNeeded();
              }
              
              widget = const Task_Widget(key: ValueKey('task_widget'));
            } else {
              // User is not authenticated - dispose alarm service
              if (_currentUser != null) {
                print('👤 User signed out: ${_currentUser!.uid}');
                _currentUser = null;
                _disposeAlarmServiceIfNeeded();
              }
              
              widget = this.widget.pageIfNotConnected != null
                  ? this.widget.pageIfNotConnected!
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
