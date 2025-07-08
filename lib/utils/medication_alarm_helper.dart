import 'package:flutter/material.dart';
import 'package:pillpall/services/alarm_service.dart';

class MedicationAlarmHelper {
  // Helper method to trigger alarm from medication widget
  static void triggerMedicationAlarm(
    BuildContext context, {
    required String medicationId,
    required Map<String, dynamic> medicationData,
  }) {
    // Use the instance method instead of static method
    AlarmService().triggerMedicationAlarm(
      context,
      medicationId: medicationId,
      medicationData: medicationData,
    );
  }

  // Helper method to format time for display
  static String formatTimeForDisplay(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute$ampm';
      }
    } catch (e) {
      print('Error formatting time: $e');
    }
    return time24;
  }

  // Helper method to check if medication is due now
  static bool isMedicationDueNow(Map<String, dynamic> medicationData) {
    try {
      final now = DateTime.now();
      final medicationDate = DateTime.tryParse(medicationData['date'] ?? '');
      final medicationTime = medicationData['time'] ?? '';
      
      if (medicationDate == null || medicationTime.isEmpty) return false;
      
      // Check if it's the same date
      final isToday = medicationDate.year == now.year &&
                     medicationDate.month == now.month &&
                     medicationDate.day == now.day;
      
      if (!isToday) return false;
      
      // Check if it's the same time (within 1 minute tolerance)
      final timeParts = medicationTime.split(':');
      if (timeParts.length >= 2) {
        final medicationHour = int.parse(timeParts[0]);
        final medicationMinute = int.parse(timeParts[1]);
        
        return (now.hour == medicationHour && 
                (now.minute == medicationMinute || 
                 now.minute == medicationMinute + 1));
      }
    } catch (e) {
      print('Error checking if medication is due: $e');
    }
    
    return false;
  }

  // Helper method to check if medication is due within next few minutes
  static bool isMedicationDueSoon(Map<String, dynamic> medicationData, {int minutesAhead = 5}) {
    try {
      final now = DateTime.now();
      final medicationDate = DateTime.tryParse(medicationData['date'] ?? '');
      final medicationTime = medicationData['time'] ?? '';
      
      if (medicationDate == null || medicationTime.isEmpty) return false;
      
      // Check if it's the same date
      final isToday = medicationDate.year == now.year &&
                     medicationDate.month == now.month &&
                     medicationDate.day == now.day;
      
      if (!isToday) return false;
      
      // Check if it's within the next few minutes
      final timeParts = medicationTime.split(':');
      if (timeParts.length >= 2) {
        final medicationHour = int.parse(timeParts[0]);
        final medicationMinute = int.parse(timeParts[1]);
        
        final medicationDateTime = DateTime(
          now.year, 
          now.month, 
          now.day, 
          medicationHour, 
          medicationMinute
        );
        
        final difference = medicationDateTime.difference(now).inMinutes;
        return difference >= 0 && difference <= minutesAhead;
      }
    } catch (e) {
      print('Error checking if medication is due soon: $e');
    }
    
    return false;
  }

  // Helper method to get time until next medication
  static String getTimeUntilMedication(Map<String, dynamic> medicationData) {
    try {
      final now = DateTime.now();
      final medicationDate = DateTime.tryParse(medicationData['date'] ?? '');
      final medicationTime = medicationData['time'] ?? '';
      
      if (medicationDate == null || medicationTime.isEmpty) return 'Unknown';
      
      final timeParts = medicationTime.split(':');
      if (timeParts.length >= 2) {
        final medicationHour = int.parse(timeParts[0]);
        final medicationMinute = int.parse(timeParts[1]);
        
        final medicationDateTime = DateTime(
          medicationDate.year, 
          medicationDate.month, 
          medicationDate.day, 
          medicationHour, 
          medicationMinute
        );
        
        final difference = medicationDateTime.difference(now);
        
        if (difference.isNegative) {
          return 'Overdue';
        } else if (difference.inDays > 0) {
          return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
        } else if (difference.inHours > 0) {
          return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
        } else {
          return 'Due now';
        }
      }
    } catch (e) {
      print('Error calculating time until medication: $e');
    }
    
    return 'Unknown';
  }
}
