import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

ValueNotifier<AuthService> authService = ValueNotifier(
  AuthService(),
); // Notifier to keep track of the number of messages

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth
      .currentUser; // Returns the currently signed-in user or null if no user is signed in

  Stream<User?> get authStateChanges => firebaseAuth
      .authStateChanges(); // Stream that emits the current user whenever the authentication state changes

  // Method to sign in a new user with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut(); // Signs out the current user
  }

  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(
      email: email,
    ); // Sends a password reset email to the user
  }

  Future<void> updateUsername({required String username}) async {
    await currentUser?.updateDisplayName(username);
  } // Updates the display name of the current user

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(
      credential,
    ); // Reauthenticates the user before deletion
    await currentUser!.delete(); // Deletes the current user account
    await firebaseAuth.signOut(); // Signs out the user after deletion
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(
      credential,
    ); // Reauthenticates the user with the current password
    await currentUser!.updatePassword(
      newPassword,
    ); // Updates the user's password
  }
}
