import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/services/alarm_service.dart';
import 'package:pillpall/services/medication_service.dart';
import 'package:pillpall/services/auth_service.dart';
import 'package:pillpall/models/medication_model.dart'; // Add this import if MedicationModel is defined here
import 'package:pillpall/utils/medication_alarm_helper.dart';
import 'package:pillpall/views/global_homebar.dart';

class Medication_Widget extends StatefulWidget {
  const Medication_Widget({super.key});

  @override
  State<Medication_Widget> createState() => _Medication_WidgetState();
}

class _Medication_WidgetState extends State<Medication_Widget> {
  DateTime _selectedDate = DateTime.now();
  final MedicationService _medicationService = MedicationService();
  bool _isLoading = false;

  // Returns the current user's ID
  String? get _currentUserId => authService.value.currentUser?.uid;

  // Method to get medications for selected date
  Stream<List<MedicationModel>> _getMedicationsForDate(DateTime date) {
    String dateString = date.toIso8601String().split('T')[0];
    return _medicationService.getMedicationsForDate(dateString);
  }

  // Method to get medication status from logs
  Future<Map<String, dynamic>> _getMedicationStatus(String medicationId, String date, String time) async {
    try {
      if (_currentUserId == null) return {'status': 'not_taken', 'data': null};

      // Query medication logs for this specific medication, date, and time
      // Note: We need to order by timestamp fields, but Firestore requires all ordered fields to exist
      final QuerySnapshot logs = await FirebaseFirestore.instance
          .collection('medication_logs')
          .where('medicationId', isEqualTo: medicationId)
          .where('userId', isEqualTo: _currentUserId)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFDDED),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title above Calendar
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Center(
                    child: Text(
                      "Medications for ${_monthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[900],
                      ),
                    ),
                  ),
                ),
                // Calendar
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CalendarDatePicker(
                        initialDate: _selectedDate,
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime(DateTime.now().year + 2),
                        onDateChanged: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Header text with selected date
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Your Medications for ${_monthName(_selectedDate.month)} ${_selectedDate.day}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[900],
                    ),
                  ),
                ),
                // Medications List filtered by selected date
                SizedBox(
                  height: 400,
                  child: StreamBuilder<List<MedicationModel>>(
                    stream: _getMedicationsForDate(_selectedDate),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Loading medications for ${_monthName(_selectedDate.month)} ${_selectedDate.day}...',
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        print('StreamBuilder Error: ${snapshot.error}');
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Error loading medications',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Please check your internet connection',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {}); // Trigger rebuild
                                },
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medication_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No medications for this date',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the + button to add medications for ${_monthName(_selectedDate.month)} ${_selectedDate.day}',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      final medications = snapshot.data!;
                      return ListView.builder(
                        itemCount: medications.length,
                        itemBuilder: (context, i) {
                          final medication = medications[i];
                          return _buildMedicationCard(medication);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: 16),

          // Original add medication button with unique hero tag
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: FloatingActionButton(
              heroTag: "add_medication_fab", // Unique hero tag
              onPressed: _isLoading
                  ? null
                  : () => _showAddMedicationDialog(_selectedDate),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.add, color: Colors.white),
              backgroundColor: _isLoading ? Colors.grey : Colors.deepPurple,
              tooltip:
                  'Add Medication for ${_monthName(_selectedDate.month)} ${_selectedDate.day}',
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 4, // Updated index for medications
        onTap: (index) {
          // Navigation is handled by the GlobalHomeBar itself
        },
      ),
    );
  }

  // Enhanced medication card with status indicators
  Widget _buildMedicationCard(MedicationModel medication) {
    final medicationName = medication.name;
    final dosage = medication.dosage;
    final time = medication.time;
    final isDueNow = MedicationAlarmHelper.isMedicationDueNow({
      'date': medication.date,
      'time': medication.time,
    });

    return FutureBuilder<Map<String, dynamic>>(
      future: _getMedicationStatus(
        medication.id ?? '',
        medication.date,
        medication.time,
      ),
      builder: (context, statusSnapshot) {
        final statusData = statusSnapshot.data ?? {'status': 'not_taken'};
        final status = statusData['status'] as String;
        final isTaken = status == 'taken';
        final isSkipped = status == 'skipped';
        
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isTaken ? Colors.grey[50] : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isTaken ? Icons.medication_liquid : Icons.medication,
                      color: isTaken 
                        ? Colors.green 
                        : isSkipped 
                          ? Colors.red
                          : isDueNow 
                            ? Colors.red 
                            : Colors.deepPurple,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicationName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isTaken 
                                ? Colors.grey[600]
                                : isDueNow
                                  ? Colors.red[900]
                                  : Colors.deepPurple[900],
                              decoration: isTaken ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          // Medication Status Indicator
                          if (statusSnapshot.hasData) ...[
                            SizedBox(height: 4),
                            if (status == 'taken')
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Taken ✓',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            else if (status == 'snoozed')
                              Row(
                                children: [
                                  Icon(Icons.snooze, color: Colors.orange, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Snoozed for ${statusData['remainingMinutes'] ?? 0}min',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            else if (status == 'skipped')
                              Row(
                                children: [
                                  Icon(Icons.cancel, color: Colors.red, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Skipped',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Icon(Icons.schedule, color: Colors.grey, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Not yet taken',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ],
                      ),
                    ),
                    if (isDueNow && !isTaken)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'DUE NOW!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleMenuAction(value, medication.id ?? '', {
                            'name': medication.name,
                            'dosage': medication.dosage,
                            'date': medication.date,
                            'time': medication.time,
                            'userId': medication.userId,
                          }),
                      itemBuilder: (context) => [
                        if (!isTaken) // Only show "Mark as Taken" if not already taken
                          PopupMenuItem(
                            value: 'mark_taken',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Mark as Taken'),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.deepPurple),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Medication Details
                Row(
                  children: [
                    Icon(Icons.science, color: Colors.blue, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Dosage: $dosage',
                      style: TextStyle(
                        color: isTaken ? Colors.grey[500] : Colors.blue,
                        fontWeight: FontWeight.w500,
                        decoration: isTaken ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),

                // Time Info
                if (time.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.teal, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Time: ${MedicationAlarmHelper.formatTimeForDisplay(time)}',
                        style: TextStyle(
                          color: isTaken ? Colors.grey[500] : Colors.teal,
                          fontWeight: FontWeight.w500,
                          decoration: isTaken ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 16),

                // Action Buttons Row
                Row(
                  children: [
                    if (isDueNow && !isTaken)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _triggerAlarmNow(medication.id ?? '', {
                            'name': medication.name,
                            'dosage': medication.dosage,
                            'date': medication.date,
                            'time': medication.time,
                            'userId': medication.userId,
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('TAKE NOW'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }  // Trigger alarm for due medication
  void _triggerAlarmNow(
    String medicationId,
    Map<String, dynamic> medicationData,
  ) {
    AlarmService().triggerMedicationAlarm(
      context,
      medicationId: medicationId,
      medicationData: medicationData,
    );
  }

  Future<void> _handleMenuAction(
    String action,
    String medicationId,
    Map<String, dynamic> medicationData,
  ) async {
    switch (action) {
      case 'mark_taken':
        await _markMedicationAsTaken(medicationId, medicationData);
        break;
      case 'edit':
        await _showEditMedicationDialog(medicationId, medicationData);
        break;
      case 'delete':
        await _showDeleteConfirmation(medicationId);
        break;
    }
  }

  // Mark medication as taken
  Future<void> _markMedicationAsTaken(
    String medicationId,
    Map<String, dynamic> medicationData,
  ) async {
    try {
      // Get the current user ID as fallback
      final currentUserId = authService.value.currentUser?.uid;
      final userId = medicationData['userId'] ?? currentUserId;
      
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Cannot mark medication as taken: User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${medicationData['name']} marked as taken!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Trigger a rebuild to show the updated status
      setState(() {});
      
      print('✅ Medication marked as taken: ${medicationData['name']}');
    } catch (e) {
      print('❌ Error marking medication as taken: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark medication as taken. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAddMedicationDialog(DateTime preselectedDate) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController dosageController = TextEditingController();
    DateTime selectedDate = preselectedDate;
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Add Medication for ${_monthName(selectedDate.month)} ${selectedDate.day}',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: dosageController,
                      decoration: InputDecoration(
                        labelText: 'Dosage (e.g., 5mg, 1 tablet)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Date Picker
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                          ),
                        ),
                        TextButton(
                          child: Text('Change'),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(DateTime.now().year - 1),
                              lastDate: DateTime(DateTime.now().year + 2),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // Time Picker
                    Row(
                      children: [
                        Expanded(
                          child: Text("Time: ${selectedTime.format(context)}"),
                        ),
                        TextButton(
                          child: Text('Pick'),
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Add Medication'),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter medication name')),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      // Format time consistently 
                      String formatTimeForDatabase(TimeOfDay time) {
                        final hour = time.hour.toString().padLeft(2, '0');
                        final minute = time.minute.toString().padLeft(2, '0');
                        return '$hour:$minute';
                      }

                      await _medicationService.addMedication(
                        MedicationModel(
                          name: nameController.text.trim(),
                          dosage: dosageController.text.trim(),
                          date: selectedDate.toIso8601String().split('T')[0],
                          time: formatTimeForDatabase(selectedTime),
                          userId: _currentUserId ?? '',
                        ),
                      );

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Medication added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      print('Error adding medication: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to add medication. Please try again.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditMedicationDialog(
    String medicationId,
    Map<String, dynamic> medicationData,
  ) async {
    TextEditingController nameController = TextEditingController(
      text: medicationData['name'] ?? '',
    );
    TextEditingController dosageController = TextEditingController(
      text: medicationData['dosage'] ?? '',
    );

    // Parse the existing date
    DateTime selectedDate;
    try {
      selectedDate = DateTime.parse(medicationData['date'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      selectedDate = DateTime.now();
    }

    // Parse the existing time
    TimeOfDay selectedTime;
    try {
      String timeStr = medicationData['time']?.toString() ?? '00:00';
      // Remove any AM/PM and convert to 24-hour format if needed
      timeStr = timeStr.replaceAll(RegExp(r'\s*(AM|PM)\s*', caseSensitive: false), '');
      
      final timeParts = timeStr.split(':');
      selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } catch (e) {
      print('Error parsing medication time: $e');
      selectedTime = TimeOfDay.now();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit Medication'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: dosageController,
                      decoration: InputDecoration(
                        labelText: 'Dosage (e.g., 5mg, 1 tablet)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Date Picker
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                          ),
                        ),
                        TextButton(
                          child: Text('Change'),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(DateTime.now().year - 1),
                              lastDate: DateTime(DateTime.now().year + 2),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // Time Picker
                    Row(
                      children: [
                        Expanded(
                          child: Text("Time: ${selectedTime.format(context)}"),
                        ),
                        TextButton(
                          child: Text('Pick'),
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Save Changes'),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter medication name')),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      // Format time consistently 
                      String formatTimeForDatabase(TimeOfDay time) {
                        final hour = time.hour.toString().padLeft(2, '0');
                        final minute = time.minute.toString().padLeft(2, '0');
                        return '$hour:$minute';
                      }

                      // Create updated medication model
                      MedicationModel updatedMedication = MedicationModel(
                        id: medicationId,
                        name: nameController.text.trim(),
                        dosage: dosageController.text.trim(),
                        date: selectedDate.toIso8601String().split('T')[0],
                        time: formatTimeForDatabase(selectedTime),
                        userId: _currentUserId ?? '',
                      );

                      await _medicationService.updateMedication(updatedMedication);

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Medication updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      print('Error updating medication: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update medication. Please try again.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(String medicationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Medication'),
        content: Text('Are you sure you want to delete this medication?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _medicationService.deleteMedication(medicationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medication deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting medication: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete medication. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
