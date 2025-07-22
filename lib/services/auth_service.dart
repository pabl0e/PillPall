import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

ValueNotifier<AuthService> authService = ValueNotifier(
  AuthService(),
); // Notifier to keep track of the number of messages

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  // Enhanced deleteAccount method with complete data cleanup
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Step 1: Reauthenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Step 2: Delete all user data from Firestore
      await _deleteAllUserData(user.uid);

      // Step 3: Delete the Firebase Auth account
      await user.delete();
      
      // Step 4: Sign out (cleanup)
      await firebaseAuth.signOut();
      
      print('Account and all associated data deleted successfully');
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
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

  // Private method to delete all user data from Firestore
  Future<void> _deleteAllUserData(String userId) async {
    final WriteBatch batch = _db.batch();
    
    try {
      print('Starting comprehensive data cleanup for user: $userId');
      
      // Delete all medications
      final medicationsQuery = await _db
          .collection('medications')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in medicationsQuery.docs) {
        batch.delete(doc.reference);
      }
      print('Queued ${medicationsQuery.docs.length} medications for deletion');

      // Delete all tasks
      final tasksQuery = await _db
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in tasksQuery.docs) {
        batch.delete(doc.reference);
      }
      print('Queued ${tasksQuery.docs.length} tasks for deletion');

      // Delete all symptoms (if you have this collection)
      try {
        final symptomsQuery = await _db
            .collection('symptoms')
            .where('userId', isEqualTo: userId)
            .get();
        
        for (var doc in symptomsQuery.docs) {
          batch.delete(doc.reference);
        }
        print('Queued ${symptomsQuery.docs.length} symptoms for deletion');
      } catch (e) {
        print('Symptoms collection not found or error: $e');
      }

      // Delete all doctor information (if you have this collection)
      try {
        final doctorsQuery = await _db
            .collection('doctors')
            .where('userId', isEqualTo: userId)
            .get();
        
        for (var doc in doctorsQuery.docs) {
          batch.delete(doc.reference);
        }
        print('Queued ${doctorsQuery.docs.length} doctor records for deletion');
      } catch (e) {
        print('Doctors collection not found or error: $e');
      }

      // Delete all appointments (if you have this collection)
      try {
        final appointmentsQuery = await _db
            .collection('appointments')
            .where('userId', isEqualTo: userId)
            .get();
        
        for (var doc in appointmentsQuery.docs) {
          batch.delete(doc.reference);
        }
        print('Queued ${appointmentsQuery.docs.length} appointments for deletion');
      } catch (e) {
        print('Appointments collection not found or error: $e');
      }

      // Delete user profile/settings (if you have this collection)
      try {
        final userProfileQuery = await _db
            .collection('users')
            .where('userId', isEqualTo: userId)
            .get();
        
        for (var doc in userProfileQuery.docs) {
          batch.delete(doc.reference);
        }
        print('Queued ${userProfileQuery.docs.length} user profiles for deletion');
      } catch (e) {
        print('User profiles collection not found or error: $e');
      }

      // Delete user preferences/settings (alternative collection name)
      try {
        final settingsQuery = await _db
            .collection('user_settings')
            .where('userId', isEqualTo: userId)
            .get();
        
        for (var doc in settingsQuery.docs) {
          batch.delete(doc.reference);
        }
        print('Queued ${settingsQuery.docs.length} user settings for deletion');
      } catch (e) {
        print('User settings collection not found or error: $e');
      }

      // Delete medication reminders (if you have this collection)
      try {
        final remindersQuery = await _db
            .collection('reminders')
            .where('userId', isEqualTo: userId)
            .get();
        
        for (var doc in remindersQuery.docs) {
          batch.delete(doc.reference);
        }
        print('Queued ${remindersQuery.docs.length} reminders for deletion');
      } catch (e) {
        print('Reminders collection not found or error: $e');
      }

      // Execute all deletions in a single batch
      await batch.commit();
      print('✅ Successfully deleted all user data from Firestore');
      
    } catch (e) {
      print('❌ Error deleting user data: $e');
      throw Exception('Failed to delete user data: $e');
    }
  }

  // Helper method to get user data statistics before deletion (optional)
  Future<Map<String, int>> getUserDataStats() async {
    try {
      final user = currentUser;
      if (user == null) return {};

      final String userId = user.uid;
      Map<String, int> stats = {};

      // Count medications
      try {
        final medicationsCount = await _db
            .collection('medications')
            .where('userId', isEqualTo: userId)
            .get()
            .then((snapshot) => snapshot.docs.length);
        stats['medications'] = medicationsCount;
      } catch (e) {
        stats['medications'] = 0;
      }

      // Count tasks
      try {
        final tasksCount = await _db
            .collection('tasks')
            .where('userId', isEqualTo: userId)
            .get()
            .then((snapshot) => snapshot.docs.length);
        stats['tasks'] = tasksCount;
      } catch (e) {
        stats['tasks'] = 0;
      }

      // Count symptoms
      try {
        final symptomsCount = await _db
            .collection('symptoms')
            .where('userId', isEqualTo: userId)
            .get()
            .then((snapshot) => snapshot.docs.length);
        stats['symptoms'] = symptomsCount;
      } catch (e) {
        stats['symptoms'] = 0;
      }

      // Count doctors
      try {
        final doctorsCount = await _db
            .collection('doctors')
            .where('userId', isEqualTo: userId)
            .get()
            .then((snapshot) => snapshot.docs.length);
        stats['doctors'] = doctorsCount;
      } catch (e) {
        stats['doctors'] = 0;
      }

      // Count appointments
      try {
        final appointmentsCount = await _db
            .collection('appointments')
            .where('userId', isEqualTo: userId)
            .get()
            .then((snapshot) => snapshot.docs.length);
        stats['appointments'] = appointmentsCount;
      } catch (e) {
        stats['appointments'] = 0;
      }

      // Count reminders
      try {
        final remindersCount = await _db
            .collection('reminders')
            .where('userId', isEqualTo: userId)
            .get()
            .then((snapshot) => snapshot.docs.length);
        stats['reminders'] = remindersCount;
      } catch (e) {
        stats['reminders'] = 0;
      }

      return stats;
    } catch (e) {
      print('Error getting user data stats: $e');
      return {};
    }
  }

  // Helper method to check if user has any data
  Future<bool> userHasData() async {
    final stats = await getUserDataStats();
    return stats.values.any((count) => count > 0);
  }

  // Test Firestore connection
  Future<bool> testFirestoreConnection() async {
    try {
      await _db.collection('test').limit(1).get();
      print('✅ Firestore connection successful');
      return true;
    } catch (e) {
      print('❌ Firestore connection failed: $e');
      return false;
    }
  }
}
