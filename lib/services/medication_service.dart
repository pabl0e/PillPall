import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpall/auth_service.dart'; 

class MedicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  bool get _isSignedIn => authService.value.currentUser != null;
  

  String? get _currentUserId => authService.value.currentUser?.uid;

  Future<void> addMedication({
    required String name,
    required String dosage,
    required DateTime date,
    required String time,
  }) async {
    try {
     
      if (!_isSignedIn) {
        throw Exception('User must be signed in to add medications');
      }

      await _db.collection('medications').add({
        'name': name.trim(),
        'dosage': dosage.trim(),
        'date': date.toIso8601String(),
        'time': time,
        'userId': _currentUserId, 
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Medication added successfully');
    } catch (e) {
      print('Error adding medication: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getMedications() {
    try {
      
      if (!_isSignedIn) {
        throw Exception('User must be signed in to view medications');
      }

      return _db
          .collection('medications')
          .where('userId', isEqualTo: _currentUserId) 
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting medications stream: $e');
      rethrow;
    }
  }

  Future<void> updateMedication(
    String id, {
    required String name,
    required String dosage,
    required DateTime date,
    required String time,
  }) async {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to update medications');
      }

      await _db.collection('medications').doc(id).update({
        'name': name.trim(),
        'dosage': dosage.trim(),
        'date': date.toIso8601String(),
        'time': time,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Medication updated successfully');
    } catch (e) {
      print('Error updating medication: $e');
      rethrow;
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to delete medications');
      }

      await _db.collection('medications').doc(id).delete();
      print('Medication deleted successfully');
    } catch (e) {
      print('Error deleting medication: $e');
      rethrow;
    }
  }

  
  Future<bool> testConnection() async {
    try {
      await _db.collection('medications').limit(1).get();
      print('Firestore connection successful');
      return true;
    } catch (e) {
      print('Firestore connection failed: $e');
      return false;
    }
  }
}
