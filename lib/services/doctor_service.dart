import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/doctor_model.dart';

class DoctorService {
  static const String _collectionName = 'doctors';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get reference to doctors collection
  CollectionReference get _doctorsCollection =>
      _firestore.collection(_collectionName);

  // Create a new doctor
  Future<String> createDoctor(Doctor doctor) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Ensure the doctor has the current user's ID
      final doctorWithUserId = doctor.copyWith(userId: currentUserId!);
      DocumentReference docRef = await _doctorsCollection.add(
        doctorWithUserId.toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create doctor: $e');
    }
  }

  // Get all doctors for current user
  Future<List<Doctor>> getAllDoctors() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot querySnapshot = await _doctorsCollection
          .where('userId', isEqualTo: currentUserId)
          .get(); // Removed orderBy to avoid issues with missing createdAt fields

      List<Doctor> doctors = querySnapshot.docs
          .map((doc) => Doctor.fromDocument(doc))
          .toList();

      // Sort locally by createdAt, handling null values
      doctors.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!); // Most recent first
      });

      return doctors;
    } catch (e) {
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  // Get doctors as a stream (real-time updates) for current user
  Stream<List<Doctor>> getDoctorsStream() {
    if (currentUserId == null) {
      return Stream.error('User not authenticated');
    }

    return _doctorsCollection
        .where('userId', isEqualTo: currentUserId)
        .snapshots() // Removed orderBy here too
        .map((snapshot) {
          List<Doctor> doctors = snapshot.docs
              .map((doc) => Doctor.fromDocument(doc))
              .toList();

          // Sort locally by createdAt, handling null values
          doctors.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!); // Most recent first
          });

          return doctors;
        });
  }

  // Get a specific doctor by ID (for current user only)
  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      DocumentSnapshot doc = await _doctorsCollection.doc(doctorId).get();
      if (doc.exists) {
        final doctor = Doctor.fromDocument(doc);
        // Verify the doctor belongs to the current user
        if (doctor.userId == currentUserId) {
          return doctor;
        } else {
          throw Exception(
            'Access denied: Doctor does not belong to current user',
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch doctor: $e');
    }
  }

  // Update a doctor (for current user only)
  Future<void> updateDoctor(String doctorId, Doctor doctor) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Verify the doctor belongs to the current user first
      final existingDoctor = await getDoctorById(doctorId);
      if (existingDoctor == null) {
        throw Exception('Doctor not found or access denied');
      }

      // Ensure the updated doctor maintains the current user's ID
      final updatedDoctor = doctor.copyWith(userId: currentUserId!);
      await _doctorsCollection.doc(doctorId).update(updatedDoctor.toMap());
    } catch (e) {
      throw Exception('Failed to update doctor: $e');
    }
  }

  // Delete a doctor (for current user only)
  Future<void> deleteDoctor(String doctorId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Verify the doctor belongs to the current user first
      final existingDoctor = await getDoctorById(doctorId);
      if (existingDoctor == null) {
        throw Exception('Doctor not found or access denied');
      }

      await _doctorsCollection.doc(doctorId).delete();
    } catch (e) {
      throw Exception('Failed to delete doctor: $e');
    }
  }

  // Search doctors by name or specialty (for current user only)
  Future<List<Doctor>> searchDoctors(String query) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get only current user's doctors
      QuerySnapshot querySnapshot = await _doctorsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      List<Doctor> allDoctors = querySnapshot.docs
          .map((doc) => Doctor.fromDocument(doc))
          .toList();

      // Filter locally by name or specialty
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

  // Get doctors by specialty (for current user only)
  Future<List<Doctor>> getDoctorsBySpecialty(String specialty) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot querySnapshot = await _doctorsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('specialties', arrayContains: specialty)
          .get();

      return querySnapshot.docs.map((doc) => Doctor.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch doctors by specialty: $e');
    }
  }

  // Get total count of doctors (for current user only)
  Future<int> getDoctorCount() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot querySnapshot = await _doctorsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get doctor count: $e');
    }
  }
}
