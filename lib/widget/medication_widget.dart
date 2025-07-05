import 'package:flutter/material.dart';
import 'package:pillpall/widget/global_homebar.dart';
import 'package:pillpall/services/medication_service.dart';

void main() {
  runApp(
    MaterialApp(home: MedicationWidget(), debugShowCheckedModeBanner: false),
  );
}

class MedicationWidget extends StatefulWidget {
  const MedicationWidget({super.key});

  @override
  State<MedicationWidget> createState() => _MedicationWidget_State();
}

class _MedicationWidget_State extends State<MedicationWidget> {
  DateTime _selectedDate = DateTime.now();
  final MedicationService _medicationService = MedicationService();

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
                // Add this header text between the calendar and the medications list
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Your Medications",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[900],
                    ),
                  ),
                ),
                // Medications List
                SizedBox(
                  height: 300, // Adjust as needed
                  child: StreamBuilder(
                    stream: _medicationService.getMedications(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No medications yet.'));
                      }
                      final meds = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: meds.length,
                        itemBuilder: (context, i) {
                          final med = meds[i];
                          final medId = med.id;
                          final medData = med.data() as Map<String, dynamic>;

                          return Card(
                            child: ListTile(
                              title: Row(
                                children: [
                                  Icon(Icons.medication, color: Colors.deepPurple, size: 22),
                                  SizedBox(width: 8),
                                  Text(medData['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      Text(medData['dosage'] ?? ''),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.teal, size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        medData['date'] != null
                                            ? _formatDateWord(medData['date'])
                                            : '',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.orange, size: 18),
                                      SizedBox(width: 4),
                                      Text(_formatTimeAMPM(medData['time'])),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    // Show edit dialog
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
                                          builder: (context, setState) {
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
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller: doseController,
                                                      decoration: InputDecoration(labelText: 'Dosage'),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                                                        ),
                                                        Spacer(),
                                                        TextButton(
                                                          child: Text('Pick'),
                                                          onPressed: () async {
                                                            DateTime? picked = await showDatePicker(
                                                              context: context,
                                                              initialDate: selectedDate,
                                                              firstDate: DateTime(DateTime.now().year - 1),
                                                              lastDate: DateTime(DateTime.now().year + 2),
                                                            );
                                                            if (picked != null) {
                                                              setState(() {
                                                                selectedDate = picked;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text("Time: ${selectedTime.format(context)}"),
                                                        Spacer(),
                                                        TextButton(
                                                          child: Text('Pick'),
                                                          onPressed: () async {
                                                            TimeOfDay? picked = await showTimePicker(
                                                              context: context,
                                                              initialTime: selectedTime,
                                                            );
                                                            if (picked != null) {
                                                              setState(() {
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
                                                    await _medicationService.updateMedication(
                                                      medId,
                                                      name: medController.text,
                                                      dosage: doseController.text,
                                                      date: selectedDate,
                                                      time: selectedTime.format(context),
                                                    );
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  } else if (value == 'delete') {
                                    // Confirm delete
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
                                      await _medicationService.deleteMedication(medId);
                                    }
                                  }
                                },
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
        padding: const EdgeInsets.only(bottom: 32.0), // Adjust value as needed
        child: FloatingActionButton(
          onPressed: () {
            // Show a dialog or navigate to a new screen for adding medication
            showDialog(
              context: context,
              builder: (context) {
                TextEditingController medController = TextEditingController();
                TextEditingController doseController = TextEditingController();
                DateTime selectedDate = DateTime.now();
                TimeOfDay selectedTime = TimeOfDay.now();

                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text('Add Medication'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: medController,
                              decoration: InputDecoration(
                                labelText: 'Medication Name',
                              ),
                            ),
                            TextField(
                              controller: doseController,
                              decoration: InputDecoration(labelText: 'Dosage'),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                                ),
                                Spacer(),
                                TextButton(
                                  child: Text('Pick'),
                                  onPressed: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(
                                        DateTime.now().year - 1,
                                      ),
                                      lastDate: DateTime(
                                        DateTime.now().year + 2,
                                      ),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        selectedDate = picked;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Time: ${selectedTime.format(context)}"),
                                Spacer(),
                                TextButton(
                                  child: Text('Pick'),
                                  onPressed: () async {
                                    TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: selectedTime,
                                    );
                                    if (picked != null) {
                                      setState(() {
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
                          onPressed: () {
                            // Handle add logic here
                            _medicationService.addMedication(
                              name: medController.text,
                              dosage: doseController.text,
                              date: selectedDate,
                              time: selectedTime.format(context),
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.deepPurple,
          tooltip: 'Add Medication',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 4, // Pills/Medication page (was 3, now 4)
        onTap: (index) {
          // Navigation is handled by the GlobalHomeBar itself
        },
      ),
    );
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

  String _formatDateWord(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    return "${_monthName(date.month)} ${date.day}, ${date.year}";
  }

  String _formatTimeAMPM(String? time) {
    if (time == null || time.isEmpty) return '';
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $ampm';
  }
}

Widget Item1() {
  return Container(
    height: 90,
    width: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      image: DecorationImage(image: AssetImage('assets/paracetamol.png')),
    ),
  );
}

Widget Item2() {
  return Container(
    height: 90,
    width: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      image: DecorationImage(image: AssetImage('assets/antihistamine.png')),
    ),
  );
}
