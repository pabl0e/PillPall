import 'package:flutter/material.dart';
import 'package:pillpall/services/task_service.dart';
import 'package:pillpall/services/doctor_service.dart';
import 'package:pillpall/widget/doctor_list.dart';
import 'package:pillpall/widget/global_homebar.dart';
import 'package:pillpall/widget/symptom_widget.dart';
import 'package:pillpall/widget/task_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final TaskService _taskService = TaskService();
  final DoctorService _doctorService = DoctorService();

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
                Row(
                  children: [
                    Text(
                      "PILL PAL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "- Your medication companion",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
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
                ), // App Title and Subtitle

                SizedBox(height: 20),

                // Calendar Section
                SizedBox(height: 20),
                // Scheduled Tasks Section
                Text(
                  "Scheduled Tasks",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Add Tasks Card
                    _SquareTaskCard(
                      label: "Add Tasks",
                      icon: Icons.add,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Task_Widget(), // Navigate to Task_Widget
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 16),
                    // Latest Tasks Cards
                    Expanded(
                      flex: 2,
                      child: StreamBuilder(
                        stream: _taskService.getTasks(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Row(
                              children: [
                                _SquareTaskCard(),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Row(
                              children: [
                                _SquareTaskCard(),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }
                          final tasks = snapshot.data!.docs.take(2).toList();
                          return Row(
                            children: List.generate(2, (i) {
                              if (i < tasks.length) {
                                final data = tasks[i].data() as Map<String, dynamic>;
                                return Expanded(
                                  child: _SquareTaskCard(
                                    label: data['title'] ?? '',
                                    icon: Icons.task_alt,
                                    date: _formatDateWord(data['startDate']),
                                    time: _formatTimeAMPM(data['startTime']),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Task_Widget(),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return Expanded(child: _SquareTaskCard());
                              }
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // My daily insights Section
                Text(
                  "My daily insights",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 20),
                // Another row for symptoms logging
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _SquareTaskCard(
                      label: "Log your symptoms",
                      icon: Icons.add,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SymptomWidget(),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 16),
                    // Latest Symptoms Cards
                    Expanded(
                      flex: 2,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('symptoms')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Row(
                              children: [
                                _SquareTaskCard(),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Row(
                              children: [
                                _SquareTaskCard(),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }
                          final symptoms = snapshot.data!.docs.take(2).toList();
                          return Row(
                            children: List.generate(2, (i) {
                              if (i < symptoms.length) {
                                final data = symptoms[i].data() as Map<String, dynamic>;
                                return Expanded(
                                  child: _SquareTaskCard(
                                    label: data['name'] ?? '',
                                    date: _formatDateWord(data['date']),
                                    time: _formatTimeAMPM(data['time']),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SymptomWidget(),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return Expanded(child: _SquareTaskCard());
                              }
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Your Doctor's Contact Details
                Text(
                  "Your Doctor's Contact Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _SquareTaskCard(
                      label: "Add Doctor",
                      icon: Icons.add,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorListScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 16),
                    // Latest Doctors Cards
                    Expanded(
                      flex: 2,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('doctors')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Row(
                              children: [
                                _SquareTaskCard(),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Row(
                              children: [
                                _SquareTaskCard(),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }
                          final doctors = snapshot.data!.docs.take(2).toList();
                          return Row(
                            children: List.generate(2, (i) {
                              if (i < doctors.length) {
                                final data = doctors[i].data() as Map<String, dynamic>;
                                return Expanded(
                                  child: _SquareTaskCard(
                                    label: data['name'] ?? '',
                                    date: data['specialty'] ?? '',
                                    time: data['phone'] ?? '',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DoctorListScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return Expanded(child: _SquareTaskCard());
                              }
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 0, // Set the selected index for highlighting
        onTap: (index) {
          // Handle navigation here
        },
      ),
    );
  }

  String _formatDateWord(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${months[date.month]} ${date.day}, ${date.year}";
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

// Add this widget below your _HomePageState class (outside of it):
class _SquareTaskCard extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? date;
  final String? time;

  const _SquareTaskCard({
    this.label = "",
    this.icon,
    this.onTap,
    this.date,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (date != null && date!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      date!,
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (time != null && time!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      time!,
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 8),
                // Icon removed here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
