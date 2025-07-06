
import 'package:flutter/material.dart';
import 'package:pillpall/widget/global_homebar.dart';
import 'package:pillpall/services/medication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationWidget extends StatefulWidget {
  const MedicationWidget({super.key});

  @override
  State<MedicationWidget> createState() => _MedicationWidgetState();
}

class _MedicationWidgetState extends State<MedicationWidget> {
  DateTime _selectedDate = DateTime.now();
  final MedicationService _medicationService = MedicationService();
  bool _isLoading = false;

  // Method to get medications for selected date
  Stream<QuerySnapshot> _getMedicationsForDate(DateTime date) {
    // Format date to match stored format (YYYY-MM-DD)
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
                      "Today is ${_monthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}",
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
                    "Medications for ${_monthName(_selectedDate.month)} ${_selectedDate.day}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[900],
                    ),
                  ),
                ),
                // Medications List filtered by selected date
                SizedBox(
                  height: 300,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getMedicationsForDate(_selectedDate),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Loading medications for ${_monthName(_selectedDate.month)} ${_selectedDate.day}...'),
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
                              Icon(Icons.error_outline, size: 48, color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                'Error loading medications',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.medication_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No medications for this date',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

                      final meds = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: meds.length,
                        itemBuilder: (context, i) {
                          final med = meds[i];
                          final medId = med.id;
                          final medData = med.data() as Map<String, dynamic>;

                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Icon(Icons.medication, color: Colors.deepPurple, size: 22),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      medData['name'] ?? 'Unknown Medication',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.format_list_numbered, color: Colors.pinkAccent, size: 18),
                                      SizedBox(width: 4),
                                      Text(medData['dosage'] ?? 'No dosage specified'),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.orange, size: 18),
                                      SizedBox(width: 4),
                                      Text(_formatTimeAMPM(medData['time'] ?? '')),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) => _handleMenuAction(value, medId, medData),
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
                            ),
                          );
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: FloatingActionButton(
          onPressed: _isLoading ? null : () => _showAddMedicationDialog(_selectedDate),
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
          tooltip: 'Add Medication for ${_monthName(_selectedDate.month)} ${_selectedDate.day}',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 4,
        onTap: (index) {
          // Navigation is handled by the GlobalHomeBar itself
        },
      ),
    );
  }

  Future<void> _handleMenuAction(String action, String medId, Map<String, dynamic> medData) async {
    if (action == 'edit') {
      await _showEditMedicationDialog(medId, medData);
    } else if (action == 'delete') {
      await _showDeleteConfirmation(medId);
    }
  }

  Future<void> _showAddMedicationDialog(DateTime preselectedDate) async {
    TextEditingController medController = TextEditingController();
    TextEditingController doseController = TextEditingController();
    DateTime selectedDate = preselectedDate; // Pre-select the calendar date
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add Medication for ${_monthName(selectedDate.month)} ${selectedDate.day}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: medController,
                      decoration: InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: doseController,
                      decoration: InputDecoration(
                        labelText: 'Dosage',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
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
                  child: Text('Add'),
                  onPressed: () async {
                    if (medController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter medication name')),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      await _medicationService.addMedication(
                        name: medController.text.trim(),
                        dosage: doseController.text.trim(),
                        date: selectedDate,
                        time: selectedTime.format(context),
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
                          content: Text('Failed to add medication. Please try again.'),
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

  Future<void> _showEditMedicationDialog(String medId, Map<String, dynamic> medData) async {
    TextEditingController medController = TextEditingController(text: medData['name']);
    TextEditingController doseController = TextEditingController(text: medData['dosage']);
    DateTime selectedDate = DateTime.tryParse(medData['date'] ?? '') ?? DateTime.now();
    TimeOfDay selectedTime;
    
    try {
      final timeParts = (medData['time'] ?? '00:00').split(':');
      selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } catch (_) {
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
                      controller: medController,
                      decoration: InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: doseController,
                      decoration: InputDecoration(
                        labelText: 'Dosage',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
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
                  child: Text('Save'),
                  onPressed: () async {
                    if (medController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter medication name')),
                      );
                      return;
                    }

                    try {
                      await _medicationService.updateMedication(
                        medId,
                        name: medController.text.trim(),
                        dosage: doseController.text.trim(),
                        date: selectedDate,
                        time: selectedTime.format(context),
                      );
                      
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
                          content: Text('Failed to update medication. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
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

  Future<void> _showDeleteConfirmation(String medId) async {
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
        await _medicationService.deleteMedication(medId);
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  String _formatTimeAMPM(String? time) {
    if (time == null || time.isEmpty) return 'No time';
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12 == 0 ? 12 : hour % 12;
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour:$minuteStr $ampm';
    } catch (e) {
      return 'Invalid time';
    }
  }
}
