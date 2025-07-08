import 'package:flutter/material.dart';
import 'package:pillpall/utils/medication_alarm_helper.dart';
import 'package:pillpall/widget/global_homebar.dart';

class AlarmTestPage extends StatefulWidget {
  const AlarmTestPage({super.key});

  @override
  State<AlarmTestPage> createState() => _AlarmTestPageState();
}

class _AlarmTestPageState extends State<AlarmTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDDED), // Match app theme
      appBar: AppBar(
        title: Text(
          'Test Medication Alarms',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        // Back button (automatically added by AppBar when there's a route to pop)
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Back',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[100]!, Colors.deepPurple[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.alarm_add,
                    size: 48,
                    color: Colors.deepPurple[700],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Test Different Medication Alarms',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try out the alarm interface with sample medications',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            
            // Sample Medications Section
            Text(
              'Sample Medications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[900],
              ),
            ),
            SizedBox(height: 16),
            
            // Test Sample Medications
            _buildTestAlarmCard(
              'Paracetamol',
              '500mg',
              '08:00',
              Colors.blue,
              Icons.medication_liquid,
            ),
            SizedBox(height: 16),
            
            _buildTestAlarmCard(
              'Ibuprofen',
              '200mg',
              '14:30',
              Colors.green,
              Icons.medication,
            ),
            SizedBox(height: 16),
            
            _buildTestAlarmCard(
              'Vitamin D',
              '1000 IU',
              '20:00',
              Colors.orange,
              Icons.health_and_safety,
            ),
            SizedBox(height: 32),
            
            // Current Time Test Section
            Text(
              'Live Test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[900],
              ),
            ),
            SizedBox(height: 16),
            
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[50]!, Colors.red[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time,
                        size: 40,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Test Alarm with Current Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This will show an alarm as if it\'s due right now',
                      style: TextStyle(color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _testCurrentTimeAlarm,
                        icon: Icon(Icons.alarm, size: 20),
                        label: Text(
                          'Test Live Alarm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Add some bottom padding to account for the navigation bar
            SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 5, // Alarm test page is at index 5
        onTap: (index) {
          // Navigation is handled by the GlobalHomeBar itself
        },
      ),
    );
  }

  Widget _buildTestAlarmCard(String name, String dosage, String time, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.science, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        dosage,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        MedicationAlarmHelper.formatTimeForDisplay(time),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _testAlarm(name, dosage, time),
              icon: Icon(Icons.play_arrow, size: 18),
              label: Text('Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testAlarm(String name, String dosage, String time) {
    final testMedicationData = {
      'name': name,
      'dosage': dosage,
      'time': time,
      'date': DateTime.now().toIso8601String(),
      'userId': 'test_user',
    };

    MedicationAlarmHelper.triggerMedicationAlarm(
      context,
      medicationId: 'test_${name.toLowerCase()}',
      medicationData: testMedicationData,
    );
  }

  void _testCurrentTimeAlarm() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final testMedicationData = {
      'name': 'Test Medication',
      'dosage': '1 tablet',
      'time': currentTime,
      'date': now.toIso8601String(),
      'userId': 'test_user',
    };

    MedicationAlarmHelper.triggerMedicationAlarm(
      context,
      medicationId: 'test_current_time',
      medicationData: testMedicationData,
    );
  }
}
