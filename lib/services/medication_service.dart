import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpall/services/auth_service.dart';

class MedicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool get _isSignedIn => authService.value.currentUser != null;
  String? get _currentUserId => authService.value.currentUser?.uid;

  // Get medications for a specific date
  Stream<QuerySnapshot> getMedicationsForDate(String dateString) {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to view medications');
      }

      print(
        '🔍 Getting medications for date: $dateString, user: $_currentUserId',
      );

      return _db
          .collection('medications')
          .where('userId', isEqualTo: _currentUserId)
          .where('date', isGreaterThanOrEqualTo: dateString)
          .where('date', isLessThan: dateString + 'Z') // Next day
          .orderBy('date')
          .orderBy('time')
          .snapshots();
    } catch (e) {
      print('Error getting medications for date: $e');
      rethrow;
    }
  }

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

      final dateString = date.toIso8601String().split('T')[0];

      print('💊 Adding medication:');
      print('  - Name: $name');
      print('  - Dosage: $dosage');
      print('  - Date: $dateString');
      print('  - Time: $time');
      print('  - User: $_currentUserId');

      await _db.collection('medications').add({
        'name': name.trim(),
        'dosage': dosage.trim(),
        'date': dateString, // Store as YYYY-MM-DD
        'time': time,
        'userId': _currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Medication added successfully');
    } catch (e) {
      print('❌ Error adding medication: $e');
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
        'date': date.toIso8601String().split('T')[0],
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

  // Get medications due now (for automatic alarm triggering)
  Future<List<Map<String, dynamic>>> getMedicationsDueNow() async {
    try {
      if (!_isSignedIn) return [];

      final now = DateTime.now();
      final currentDate = now.toIso8601String().split('T')[0];
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      print('🔍 Checking for medications due at $currentTime on $currentDate');

      final snapshot = await _db
          .collection('medications')
          .where('userId', isEqualTo: _currentUserId)
          .where('date', isEqualTo: currentDate)
          .where('time', isEqualTo: currentTime)
          .get();

      print('📊 Query returned ${snapshot.docs.length} medications');

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error getting medications due now: $e');
      return [];
    }
  }

  // Debug method to check all medications for today
  Future<void> debugTodaysMedications() async {
    try {
      if (!_isSignedIn) return;

      final now = DateTime.now();
      final currentDate = now.toIso8601String().split('T')[0];

      final snapshot = await _db
          .collection('medications')
          .where('userId', isEqualTo: _currentUserId)
          .where('date', isEqualTo: currentDate)
          .get();

      print('🐛 DEBUG: All medications for today ($currentDate):');
      if (snapshot.docs.isEmpty) {
        print('  📭 No medications found');
      } else {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          print(
            '  📋 ${data['name']} - ${data['time']} - ${data['dosage']} (ID: ${doc.id})',
          );
        }
      }
    } catch (e) {
      print('❌ Error in debug: $e');
    }
  }
}
