import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/doctor_model.dart';

class DoctorService {
  static const String _collectionName = 'doctors';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get reference to doctors collection
  CollectionReference get _doctorsCollection =>
      _firestore.collection(_collectionName);

  // Create a new doctor
  Future<String> createDoctor(Doctor doctor) async {
    try {
      DocumentReference docRef = await _doctorsCollection.add(doctor.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create doctor: $e');
    }
  }

  // Get all doctors
  Future<List<Doctor>> getAllDoctors() async {
    try {
      QuerySnapshot querySnapshot = await _doctorsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => Doctor.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  // Get doctors as a stream (real-time updates)
  Stream<List<Doctor>> getDoctorsStream() {
    return _doctorsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Doctor.fromDocument(doc)).toList(),
        );
  }

  // Get a specific doctor by ID
  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      DocumentSnapshot doc = await _doctorsCollection.doc(doctorId).get();
      if (doc.exists) {
        return Doctor.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch doctor: $e');
    }
  }

  // Update a doctor
  Future<void> updateDoctor(String doctorId, Doctor doctor) async {
    try {
      await _doctorsCollection.doc(doctorId).update(doctor.toMap());
    } catch (e) {
      throw Exception('Failed to update doctor: $e');
    }
  }

  // Delete a doctor
  Future<void> deleteDoctor(String doctorId) async {
    try {
      await _doctorsCollection.doc(doctorId).delete();
    } catch (e) {
      throw Exception('Failed to delete doctor: $e');
    }
  }

  // Search doctors by name or specialty
  Future<List<Doctor>> searchDoctors(String query) async {
    try {
      // Note: For better search functionality, consider using Algolia or similar
      // This is a basic implementation
      QuerySnapshot querySnapshot = await _doctorsCollection.get();

      List<Doctor> allDoctors = querySnapshot.docs
          .map((doc) => Doctor.fromDocument(doc))
          .toList();

      // Filter locally (for demonstration)
      return allDoctors.where((doctor) {
        return doctor.name.toLowerCase().contains(query.toLowerCase()) ||
            doctor.specialties.any(
              (specialty) =>
                  specialty.toLowerCase().contains(query.toLowerCase()),
            );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search doctors: $e');
    }
  }

  // Get doctors by specialty
  Future<List<Doctor>> getDoctorsBySpecialty(String specialty) async {
    try {
      QuerySnapshot querySnapshot = await _doctorsCollection
          .where('specialties', arrayContains: specialty)
          .get();

      return querySnapshot.docs.map((doc) => Doctor.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch doctors by specialty: $e');
    }
  }

  // Get total count of doctors
  Future<int> getDoctorCount() async {
    try {
      QuerySnapshot querySnapshot = await _doctorsCollection.get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get doctor count: $e');
    }
  }
}
