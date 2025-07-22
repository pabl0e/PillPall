import 'package:flutter/material.dart';
import 'package:pillpall/services/alarm_service.dart';
import 'package:pillpall/services/medication_service.dart';

class DebugHelper {
  static Widget buildDebugButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showDebugInfo(context), // Updated call
      child: Icon(Icons.bug_report),
      backgroundColor: Colors.orange,
      tooltip: 'Debug Alarm Service',
    );
  }

  // ✅ FIXED: Made method public by removing underscore
  static void showDebugInfo(BuildContext context) {
    print('🐛 === DEBUG INFO REQUESTED ===');
    
    // Debug AlarmService
    AlarmService().debugServiceStatus();
    
    // Debug today's medications
    MedicationService().debugTodaysMedications();
    
    // Show current time
    final now = DateTime.now();
    print('🕐 Current time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
    print('📅 Current date: ${now.toIso8601String().split('T')[0]}');
    
    // Show in UI too
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug info printed to console! Check your IDE debug console.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
    
    print('🐛 === END DEBUG INFO ===');
  }
}
