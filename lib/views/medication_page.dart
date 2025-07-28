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

  // Enhanced medication card with TEST ALARM button
  Widget _buildMedicationCard(MedicationModel medication) {
    final medicationName = medication.name;
    final dosage = medication.dosage;
    final time = medication.time;
    final isDueNow = MedicationAlarmHelper.isMedicationDueNow({
      'date': medication.date,
      'time': medication.time,
    });

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medication,
                  color: isDueNow ? Colors.red : Colors.deepPurple,
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    medicationName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDueNow
                          ? Colors.red[900]
                          : Colors.deepPurple[900],
                    ),
                  ),
                ),
                if (isDueNow)
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
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
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
                      color: Colors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

            SizedBox(height: 16),

            // Action Buttons Row
            Row(
              children: [
                if (isDueNow)
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
  }

  // Trigger alarm for due medication
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
      case 'edit':
        await _showEditMedicationDialog(medicationId, medicationData);
        break;
      case 'delete':
        await _showDeleteConfirmation(medicationId);
        break;
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
