import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/symptom_model.dart';

class SymptomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Collection reference
  CollectionReference get _symptomsCollection =>
      _firestore.collection('symptoms');

  // Create a new symptom
  Future<String> createSymptom(Symptom symptom) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final symptomWithUserId = symptom.copyWith(userId: currentUserId!);
      final docRef = await _symptomsCollection.add(symptomWithUserId.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create symptom: $e');
    }
  }

  // Get all symptoms for current user
  Future<List<Symptom>> getAllSymptoms() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      try {
        // Try with orderBy first (requires index)
        final querySnapshot = await _symptomsCollection
            .where('userId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .get();

        return querySnapshot.docs
            .map((doc) => Symptom.fromDocument(doc))
            .toList();
      } catch (indexError) {
        // If index is not ready, fallback to simple query without orderBy
        print('Index not ready, using fallback query: $indexError');

        final querySnapshot = await _symptomsCollection
            .where('userId', isEqualTo: currentUserId)
            .get();

        final symptoms = querySnapshot.docs
            .map((doc) => Symptom.fromDocument(doc))
            .toList();

        // Sort in memory since we can't use orderBy
        symptoms.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return symptoms;
      }
    } catch (e) {
      throw Exception('Failed to fetch symptoms: $e');
    }
  }

  // Get symptoms for a specific date
  Future<List<Symptom>> getSymptomsForDate(DateTime date) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Create start and end of the day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _symptomsCollection
          .where('userId', isEqualTo: currentUserId)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Symptom.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch symptoms for date: $e');
    }
  }

  // Get today's symptoms
  Future<List<Symptom>> getTodaysSymptoms() async {
    return getSymptomsForDate(DateTime.now());
  }

  // Get symptoms for date range
  Future<List<Symptom>> getSymptomsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _symptomsCollection
          .where('userId', isEqualTo: currentUserId)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Symptom.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch symptoms for date range: $e');
    }
  }

  // Update a symptom
  Future<void> updateSymptom(Symptom symptom) async {
    try {
      if (symptom.id == null) {
        throw Exception('Symptom ID is required for update');
      }

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Ensure the symptom belongs to the current user
      final updatedSymptom = symptom.copyWith(userId: currentUserId!);

      await _symptomsCollection.doc(symptom.id).update(updatedSymptom.toMap());
    } catch (e) {
      throw Exception('Failed to update symptom: $e');
    }
  }

  // Delete a symptom
  Future<void> deleteSymptom(String symptomId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // First verify the symptom belongs to the current user
      final doc = await _symptomsCollection.doc(symptomId).get();
      if (!doc.exists) {
        throw Exception('Symptom not found');
      }

      final symptomData = doc.data() as Map<String, dynamic>;
      if (symptomData['userId'] != currentUserId) {
        throw Exception('Unauthorized to delete this symptom');
      }

      await _symptomsCollection.doc(symptomId).delete();
    } catch (e) {
      throw Exception('Failed to delete symptom: $e');
    }
  }

  // Search symptoms by text
  Future<List<Symptom>> searchSymptoms(String query) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final allSymptoms = await getAllSymptoms();
      return allSymptoms
          .where(
            (symptom) =>
                symptom.text.toLowerCase().contains(query.toLowerCase()) ||
                (symptom.tags?.any(
                      (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                    ) ??
                    false),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search symptoms: $e');
    }
  }

  // Get symptoms by severity
  Future<List<Symptom>> getSymptomsBySeverity(String severity) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _symptomsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('severity', isEqualTo: severity)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Symptom.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch symptoms by severity: $e');
    }
  }

  // Get unique dates with symptoms
  Future<List<DateTime>> getDatesWithSymptoms() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _symptomsCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      final dates = <DateTime>{};
      for (final doc in querySnapshot.docs) {
        final symptom = Symptom.fromDocument(doc);
        final date = DateTime(
          symptom.timestamp.year,
          symptom.timestamp.month,
          symptom.timestamp.day,
        );
        dates.add(date);
      }

      return dates.toList()..sort((a, b) => b.compareTo(a));
    } catch (e) {
      throw Exception('Failed to fetch dates with symptoms: $e');
    }
  }

  // Get symptom count for date
  Future<int> getSymptomCountForDate(DateTime date) async {
    try {
      final symptoms = await getSymptomsForDate(date);
      return symptoms.length;
    } catch (e) {
      return 0;
    }
  }

  // Real-time stream of symptoms for a specific date
  Stream<List<Symptom>> symptomsStreamForDate(DateTime date) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _symptomsCollection
        .where('userId', isEqualTo: currentUserId)
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Symptom.fromDocument(doc)).toList(),
        );
  }

  // Real-time stream of all symptoms
  Stream<List<Symptom>> symptomsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _symptomsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Symptom.fromDocument(doc)).toList(),
        );
  }

  // Simple test method to check authentication and connection
  Future<int> getSymptomCount() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _symptomsCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get symptom count: $e');
    }
  }
}
