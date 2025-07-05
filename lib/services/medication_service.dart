import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addMedication({
    required String name,
    required String dosage,
    required DateTime date,
    required String time,
  }) async {
    await _db.collection('medications').add({
      'name': name,
      'dosage': dosage,
      'date': date.toIso8601String(),
      'time': time,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMedications() {
    return _db.collection('medications').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateMedication(
    String id, {
    required String name,
    required String dosage,
    required DateTime date,
    required String time,
  }) async {
    await _db.collection('medications').doc(id).update({
      'name': name,
      'dosage': dosage,
      'date': date.toIso8601String(),
      'time': time,
    });
  }

  Future<void> deleteMedication(String id) async {
    await _db.collection('medications').doc(id).delete();
  }
}