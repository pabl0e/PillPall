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
        'dateOnly': date.toIso8601String().split('T')[0], // Add date-only field for filtering
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

  // New method to get medications for a specific date
  Stream<QuerySnapshot> getMedicationsForDate(String dateString) {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to view medications');
      }

      return _db
          .collection('medications')
          .where('userId', isEqualTo: _currentUserId)
          .where('dateOnly', isEqualTo: dateString) // Filter by specific date
          .orderBy('time') // Order by time for the day
          .snapshots();
    } catch (e) {
      print('Error getting medications for date: $e');
      rethrow;
    }
  }

  // Keep the original method for getting all medications
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
        'dateOnly': date.toIso8601String().split('T')[0], // Update date-only field
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
}
