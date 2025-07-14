import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpall/auth_service.dart';
import 'package:pillpall/models/medication_model.dart';

class MedicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool get _isSignedIn => authService.value.currentUser != null;
  String? get _currentUserId => authService.value.currentUser?.uid;

  // Get medications for a specific date
  Stream<List<MedicationModel>> getMedicationsForDate(String dateString) {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to view medications');
    }
    return _db
        .collection('medications')
        .where('userId', isEqualTo: _currentUserId)
        .where('date', isEqualTo: dateString)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicationModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addMedication(MedicationModel medication) async {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to add medications');
    }
    await _db.collection('medications').add(medication.toFirestore());
  }

  Stream<List<MedicationModel>> getMedications() {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to view medications');
    }
    return _db
        .collection('medications')
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicationModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateMedication(MedicationModel medication) async {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to update medications');
    }
    await _db
        .collection('medications')
        .doc(medication.id)
        .update(medication.toFirestore());
  }

  Future<void> deleteMedication(String id) async {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to delete medications');
    }
    await _db.collection('medications').doc(id).delete();
  }

  // Get medications due now (for automatic alarm triggering)
  Future<List<MedicationModel>> getMedicationsDueNow() async {
    if (!_isSignedIn) return [];
    final now = DateTime.now();
    final currentDate = now.toIso8601String().split('T')[0];
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final snapshot = await _db
        .collection('medications')
        .where('userId', isEqualTo: _currentUserId)
        .where('date', isEqualTo: currentDate)
        .where('time', isEqualTo: currentTime)
        .get();
    return snapshot.docs
        .map((doc) => MedicationModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Debug method to check all medications for today
  Future<void> debugTodaysMedications() async {
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
        final med = MedicationModel.fromFirestore(doc.data(), doc.id);
        print('  📋 ${med.name} - ${med.time} - ${med.dosage} (ID: ${med.id})');
      }
    }
  }
}
