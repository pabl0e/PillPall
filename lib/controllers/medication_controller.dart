import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/models/medication_model.dart';
import 'package:pillpall/services/medication_service.dart';
import 'package:pillpall/services/auth_service.dart';
import 'package:pillpall/services/alarm_service.dart';

class MedicationController extends ChangeNotifier {
  final MedicationService _medicationService = MedicationService();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Getters
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get currentUserId => authService.value.currentUser?.uid;

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Update selected date
  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Get medications for selected date
  Stream<List<MedicationModel>> getMedicationsForDate(DateTime date) {
    String dateString = date.toIso8601String().split('T')[0];
    return _medicationService.getMedicationsForDate(dateString);
  }

  // Get medication status from logs
  Future<Map<String, dynamic>> getMedicationStatus(String medicationId, String date, String time) async {
    try {
      if (currentUserId == null) return {'status': 'not_taken', 'data': null};

      // Query medication logs for this specific medication, date, and time
      final QuerySnapshot logs = await FirebaseFirestore.instance
          .collection('medication_logs')
          .where('medicationId', isEqualTo: medicationId)
          .where('userId', isEqualTo: currentUserId)
          .limit(10) // Get recent logs
          .get();

      if (logs.docs.isEmpty) {
        return {'status': 'not_taken', 'data': null};
      }

      // Sort logs by most recent timestamp manually
      final sortedLogs = logs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        Timestamp? timestamp;
        
        if (data['takenAt'] != null) {
          timestamp = data['takenAt'] as Timestamp;
        } else if (data['snoozedAt'] != null) {
          timestamp = data['snoozedAt'] as Timestamp;
        } else if (data['skippedAt'] != null) {
          timestamp = data['skippedAt'] as Timestamp;
        }
        
        return {'doc': doc, 'data': data, 'timestamp': timestamp};
      }).toList();

      // Sort by timestamp descending (most recent first)
      sortedLogs.sort((a, b) {
        final aTime = a['timestamp'] as Timestamp?;
        final bTime = b['timestamp'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      if (sortedLogs.isEmpty) {
        return {'status': 'not_taken', 'data': null};
      }

      final logData = sortedLogs.first['data'] as Map<String, dynamic>;
      final status = logData['status'] ?? 'not_taken';
      
      // For snoozed medications, check if snooze period has ended
      if (status == 'snoozed') {
        final snoozedAt = logData['snoozedAt'] as Timestamp?;
        final snoozeMinutes = logData['snoozeMinutes'] as int? ?? 0;
        
        if (snoozedAt != null) {
          final snoozedTime = snoozedAt.toDate();
          final snoozeEndTime = snoozedTime.add(Duration(minutes: snoozeMinutes));
          final now = DateTime.now();
          
          if (now.isAfter(snoozeEndTime)) {
            return {'status': 'not_taken', 'data': logData}; // Snooze period ended
          } else {
            final remainingMinutes = snoozeEndTime.difference(now).inMinutes;
            return {'status': 'snoozed', 'data': logData, 'remainingMinutes': remainingMinutes};
          }
        }
      }
      
      return {'status': status, 'data': logData};
    } catch (e) {
      print('Error getting medication status: $e');
      return {'status': 'not_taken', 'data': null};
    }
  }

  // Mark medication as taken
  Future<bool> markMedicationAsTaken(String medicationId, Map<String, dynamic> medicationData) async {
    try {
      final userId = medicationData['userId'] ?? currentUserId;
      
      if (userId == null) {
        print('❌ Cannot mark medication as taken: User not logged in');
        return false;
      }

      await FirebaseFirestore.instance.collection('medication_logs').add({
        'medicationId': medicationId,
        'medicationName': medicationData['name'],
        'dosage': medicationData['dosage'],
        'scheduledTime': medicationData['time'],
        'takenAt': FieldValue.serverTimestamp(),
        'status': 'taken',
        'userId': userId,
      });

      print('✅ Medication marked as taken: ${medicationData['name']}');
      notifyListeners(); // Notify UI to update
      return true;
    } catch (e) {
      print('❌ Error marking medication as taken: $e');
      return false;
    }
  }

  // Trigger alarm for due medication
  void triggerMedicationAlarm(BuildContext context, String medicationId, Map<String, dynamic> medicationData) {
    AlarmService().triggerMedicationAlarm(
      context,
      medicationId: medicationId,
      medicationData: medicationData,
    );
  }

  // Add new medication
  Future<bool> addMedication(MedicationModel medication) async {
    try {
      setLoading(true);
      await _medicationService.addMedication(medication);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      print('Error adding medication: $e');
      return false;
    }
  }

  // Update medication
  Future<bool> updateMedication(MedicationModel medication) async {
    try {
      setLoading(true);
      await _medicationService.updateMedication(medication);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      print('Error updating medication: $e');
      return false;
    }
  }

  // Delete medication
  Future<bool> deleteMedication(String medicationId) async {
    try {
      await _medicationService.deleteMedication(medicationId);
      return true;
    } catch (e) {
      print('Error deleting medication: $e');
      return false;
    }
  }

  // Format time for database
  String formatTimeForDatabase(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get month name
  String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }
}
