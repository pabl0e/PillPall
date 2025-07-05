// Debug utility to test Firestore connection
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> testFirestoreConnection() async {
  try {
    print('Testing Firestore connection...');

    // Check authentication
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ User not authenticated');
      return;
    }
    print('✅ User authenticated: ${user.uid}');

    // Test basic Firestore write
    try {
      await FirebaseFirestore.instance.collection('test').doc('test_doc').set({
        'test': 'data',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Basic Firestore write successful');
    } catch (e) {
      print('❌ Basic Firestore write failed: $e');
    }

    // Test basic Firestore read
    try {
      final doc = await FirebaseFirestore.instance
          .collection('test')
          .doc('test_doc')
          .get();
      print('✅ Basic Firestore read successful: ${doc.exists}');
    } catch (e) {
      print('❌ Basic Firestore read failed: $e');
    }

    // Test symptoms collection without orderBy
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('symptoms')
          .where('userId', isEqualTo: user.uid)
          .get();
      print(
        '✅ Symptoms query without orderBy successful: ${querySnapshot.docs.length} docs',
      );
    } catch (e) {
      print('❌ Symptoms query without orderBy failed: $e');
    }

    // Test symptoms collection with orderBy (requires index)
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('symptoms')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();
      print(
        '✅ Symptoms query with orderBy successful: ${querySnapshot.docs.length} docs',
      );
    } catch (e) {
      print('❌ Symptoms query with orderBy failed (index may be building): $e');
    }

    // Clean up test document
    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('test_doc')
          .delete();
      print('✅ Test cleanup successful');
    } catch (e) {
      print('❌ Test cleanup failed: $e');
    }
  } catch (e) {
    print('❌ General error: $e');
  }
}
