import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/services/auth_service.dart'; // Import your auth service
import 'package:pillpall/views/doctor_list.dart';
import 'package:pillpall/views/global_homebar.dart';
import 'package:pillpall/views/symptom_page.dart';
import 'package:pillpall/views/task_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();

  // Helper method to get current user ID
  String? get _currentUserId => authService.value.currentUser?.uid;

  // Helper method to get severity color
  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.deepPurple;
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
                ),
                SizedBox(height: 20),
                // Scheduled Tasks Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Scheduled Tasks",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (_selectedDate.toIso8601String().split('T')[0] != DateTime.now().toIso8601String().split('T')[0]) ...[
                          SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.deepPurple,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatSelectedDate(_selectedDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
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
                            builder: (context) => Task_Widget(),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 16),
                    // Tasks for Selected Date
                    Expanded(
                      flex: 2,
                      child: StreamBuilder<QuerySnapshot>(
                        key: ValueKey('tasks_${_selectedDate.toIso8601String().split('T')[0]}'), // Force rebuild on date change
                        stream: FirebaseFirestore.instance
                            .collection('tasks')
                            .where('userId', isEqualTo: _currentUserId)
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Row(
                              children: [
                                _SquareTaskCard(label: "Loading..."),
                                SizedBox(width: 16),
                                _SquareTaskCard(label: "Loading..."),
                              ],
                            );
                          }

                          if (snapshot.hasError) {
                            print('Tasks stream error: ${snapshot.error}');
                            return Row(
                              children: [
                                _SquareTaskCard(label: "Error loading tasks"),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }

                          // Check if we have data before filtering
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Row(
                              children: [
                                _SquareTaskCard(label: "No tasks for selected date"),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }

                          // Filter tasks for the selected date
                          final selectedDateString = _selectedDate.toIso8601String().split('T')[0];
                          print('🗓️ Filtering tasks for selected date: $selectedDateString');
                          print('🗓️ Total tasks in database: ${snapshot.data!.docs.length}');
                          
                          final filteredTasks = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            
                            // Debug: print all available fields for first few documents
                            if (snapshot.data!.docs.indexOf(doc) < 3) {
                              print('🗓️ Task document fields: ${data.keys.toList()}');
                              print('🗓️ Task data: $data');
                            }
                            
                            // Check different possible date fields
                            String? taskDate;
                            
                            // Try to get date from different fields
                            if (data['startDateOnly'] != null) {
                              taskDate = data['startDateOnly'].toString();
                            } else if (data['startDate'] != null) {
                              taskDate = data['startDate'].toString().split('T')[0];
                            } else if (data['date'] != null) {
                              taskDate = data['date'].toString().split('T')[0];
                            } else if (data['createdAt'] != null) {
                              // Extract date from createdAt timestamp
                              try {
                                if (data['createdAt'] is Timestamp) {
                                  taskDate = (data['createdAt'] as Timestamp).toDate().toIso8601String().split('T')[0];
                                } else if (data['createdAt'] is String) {
                                  taskDate = DateTime.tryParse(data['createdAt'])?.toIso8601String().split('T')[0];
                                }
                              } catch (e) {
                                print('Error parsing date from createdAt: $e');
                              }
                            }
                            
                            print('🗓️ Task date: $taskDate, Selected: $selectedDateString, Match: ${taskDate == selectedDateString}');
                            
                            // Return true if dates match
                            return taskDate == selectedDateString;
                          }).take(2).toList();

                          if (filteredTasks.isEmpty) {
                            return Row(
                              children: [
                                _SquareTaskCard(label: "No tasks for selected date"),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }

                          print('🗓️ Found ${filteredTasks.length} filtered tasks for date: $selectedDateString');
                          return Row(
                            children: List.generate(2, (i) {
                              if (i < filteredTasks.length) {
                                final data = filteredTasks[i].data() as Map<String, dynamic>;
                                return Expanded(
                                  child: _SquareTaskCard(
                                    label: data['title'] ?? 'Untitled Task',
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
                ),
                SizedBox(height: 25),
                // My daily insights Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "My daily insights",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (_selectedDate.toIso8601String().split('T')[0] != DateTime.now().toIso8601String().split('T')[0]) ...[
                          SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.deepPurple,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatSelectedDate(_selectedDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Symptoms row - ENHANCED with time and severity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
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
                    // Symptoms for Selected Date
                    Expanded(
                      flex: 2,
                      child: StreamBuilder<QuerySnapshot>(
                        key: ValueKey('symptoms_${_selectedDate.toIso8601String().split('T')[0]}'), // Force rebuild on date change
                        stream: _currentUserId != null
                            ? FirebaseFirestore.instance
                                  .collection('symptoms')
                                  .where('userId', isEqualTo: _currentUserId)
                                  .orderBy('createdAt', descending: true)
                                  .snapshots()
                            : Stream.empty(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Row(
                              children: [
                                _SquareTaskCard(label: "Loading..."),
                                SizedBox(width: 16),
                                _SquareTaskCard(label: "Loading..."),
                              ],
                            );
                          }

                          if (snapshot.hasError) {
                            print('Symptoms stream error: ${snapshot.error}');
                            return Row(
                              children: [
                                _SquareTaskCard(
                                  label: "Error loading symptoms",
                                ),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }

                          // Check if we have data before filtering
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Row(
                              children: [
                                _SquareTaskCard(label: "No symptoms for selected date"),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }

                          // Filter symptoms for the selected date
                          final selectedDateString = _selectedDate.toIso8601String().split('T')[0];
                          print('🗓️ Filtering symptoms for selected date: $selectedDateString');
                          print('🗓️ Total symptoms in database: ${snapshot.data!.docs.length}');
                          
                          final filteredSymptoms = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            
                            // Debug: print all available fields for first few documents
                            if (snapshot.data!.docs.indexOf(doc) < 3) {
                              print('🗓️ Symptom document fields: ${data.keys.toList()}');
                              print('🗓️ Symptom data: $data');
                            }
                            
                            // Check different possible date fields
                            String? symptomDate;
                            
                            // Try to get date from different fields
                            if (data['date'] != null) {
                              symptomDate = data['date'].toString().split('T')[0];
                            } else if (data['createdAt'] != null) {
                              // Extract date from createdAt timestamp
                              try {
                                if (data['createdAt'] is Timestamp) {
                                  symptomDate = (data['createdAt'] as Timestamp).toDate().toIso8601String().split('T')[0];
                                } else if (data['createdAt'] is String) {
                                  symptomDate = DateTime.tryParse(data['createdAt'])?.toIso8601String().split('T')[0];
                                }
                              } catch (e) {
                                print('Error parsing date from createdAt: $e');
                              }
                            }
                            
                            print('🗓️ Symptom date: $symptomDate, Selected: $selectedDateString, Match: ${symptomDate == selectedDateString}');
                            
                            // Return true if dates match
                            return symptomDate == selectedDateString;
                          }).take(2).toList();

                          if (filteredSymptoms.isEmpty) {
                            return Row(
                              children: [
                                _SquareTaskCard(label: "No symptoms for selected date"),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }

                          return Row(
                            children: List.generate(2, (i) {
                              if (i < filteredSymptoms.length) {
                                final data =
                                    filteredSymptoms[i].data() as Map<String, dynamic>;

                                // ✅ ENHANCED: Get symptom details with debugging
                                final symptomText =
                                    data['text'] ??
                                    data['name'] ??
                                    'Unknown Symptom';
                                final severity = data['severity'] as String?;

                                // ✅ FIXED: Better time handling with multiple fallbacks
                                String? displayTime;

                                // Try different time field names and formats
                                final timeField = data['time'];
                                final dateField = data['date'];
                                final createdAtField = data['createdAt'];

                                print('🐛 Symptom data for ${symptomText}:');
                                print('  - time field: $timeField');
                                print('  - date field: $dateField');
                                print('  - createdAt field: $createdAtField');
                                print('  - severity: $severity');

                                // Try to get time from various sources
                                if (timeField != null &&
                                    timeField.toString().isNotEmpty) {
                                  displayTime = _formatSymptomTime(
                                    timeField.toString(),
                                  );
                                } else if (createdAtField != null) {
                                  // If no time field, try to extract time from createdAt timestamp
                                  displayTime = _formatTimestampTime(
                                    createdAtField,
                                  );
                                } else if (dateField != null) {
                                  // Try to extract time from date field if it contains time
                                  displayTime = _formatDateTimeField(
                                    dateField.toString(),
                                  );
                                }

                                print('  - final displayTime: $displayTime');

                                // ✅ ENHANCED: Truncate long symptom text for display
                                final displayText = symptomText.length > 12
                                    ? '${symptomText.substring(0, 12)}...'
                                    : symptomText;

                                return Expanded(
                                  child: _SymptomCard(
                                    label: displayText,
                                    time: displayTime,
                                    severity: severity,
                                    severityColor: _getSeverityColor(severity),
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
                ),
                SizedBox(height: 25),
                // Your Doctor's Contact Details - FIXED with userId filter
                Text(
                  "Your Doctor's Contact Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
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
                    // Latest Doctors Cards - FIXED
                    Expanded(
                      flex: 2,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _currentUserId != null
                            ? FirebaseFirestore.instance
                                  .collection('doctors')
                                  .where(
                                    'userId',
                                    isEqualTo: _currentUserId,
                                  ) // Filter by user
                                  .orderBy('createdAt', descending: true)
                                  .limit(2) // Limit to 2 for efficiency
                                  .snapshots()
                            : Stream.empty(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Row(
                              children: [
                                _SquareTaskCard(label: "Loading..."),
                                SizedBox(width: 16),
                                _SquareTaskCard(label: "Loading..."),
                              ],
                            );
                          }

                          if (snapshot.hasError) {
                            print('Doctors stream error: ${snapshot.error}');
                            return Row(
                              children: [
                                _SquareTaskCard(label: "Error loading doctors"),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Row(
                              children: [
                                _SquareTaskCard(label: "No doctors added"),
                                SizedBox(width: 16),
                                _SquareTaskCard(),
                              ],
                            );
                          }

                          final doctors = snapshot.data!.docs.take(2).toList();
                          return Row(
                            children: List.generate(2, (i) {
                              if (i < doctors.length) {
                                final data =
                                    doctors[i].data() as Map<String, dynamic>;
                                
                                // Debug print to check doctor data
                                print('🩺 Doctor data: $data');
                                print('🩺 All keys: ${data.keys.toList()}');
                                
                                final doctorName = data['name']?.toString().trim() ?? 'Unknown Doctor';
                                
                                // Handle specialties array - get the first specialty
                                String specialty = '';
                                if (data['specialties'] is List && (data['specialties'] as List).isNotEmpty) {
                                  specialty = (data['specialties'] as List)[0].toString().trim();
                                } else if (data['specialty']?.toString().trim().isNotEmpty == true) {
                                  specialty = data['specialty'].toString().trim();
                                }
                                
                                // Handle mobile number
                                final phone = data['mobileNumber']?.toString().trim() ?? 
                                             data['phone']?.toString().trim() ?? 
                                             data['phoneNumber']?.toString().trim() ?? 
                                             '';
                                
                                print('🩺 Parsed: name=$doctorName, specialty=$specialty, phone=$phone');
                                print('🩺 Specialty empty? ${specialty.isEmpty}');
                                print('🩺 Phone empty? ${phone.isEmpty}');
                                
                                return Expanded(
                                  child: _SquareTaskCard(
                                    label: doctorName,
                                    date: specialty,
                                    time: phone,
                                    icon: Icons.local_hospital,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DoctorListScreen(),
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
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 0,
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
      '',
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
    return "${months[date.month]} ${date.day}, ${date.year}";
  }

  String _formatSelectedDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    
    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == today.add(Duration(days: 1))) {
      return 'Tomorrow';
    } else if (selectedDay == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return "${months[date.month]} ${date.day}";
    }
  }

  String _formatTimeAMPM(String? time) {
    if (time == null || time.isEmpty) return '';
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

  // ✅ NEW: Enhanced time formatting specifically for symptoms
  String? _formatSymptomTime(String timeStr) {
    if (timeStr.isEmpty) return null;

    try {
      // Handle HH:MM format
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          final ampm = hour >= 12 ? 'PM' : 'AM';
          hour = hour % 12 == 0 ? 12 : hour % 12;
          final minuteStr = minute.toString().padLeft(2, '0');
          return '$hour:$minuteStr $ampm';
        }
      }

      // Handle other time formats
      return timeStr; // Return as-is if we can't parse it
    } catch (e) {
      print('Error formatting symptom time: $e');
      return timeStr; // Return original if parsing fails
    }
  }

  // ✅ NEW: Format time from Firestore timestamp
  String? _formatTimestampTime(dynamic timestamp) {
    try {
      DateTime? dateTime;

      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.tryParse(timestamp);
      }

      if (dateTime != null) {
        final hour = dateTime.hour;
        final minute = dateTime.minute;
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour % 12 == 0 ? 12 : hour % 12;
        final minuteStr = minute.toString().padLeft(2, '0');
        return '$displayHour:$minuteStr $ampm';
      }
    } catch (e) {
      print('Error formatting timestamp time: $e');
    }
    return null;
  }

  // ✅ NEW: Format time from date field that might contain time
  String? _formatDateTimeField(String dateStr) {
    try {
      final dateTime = DateTime.tryParse(dateStr);
      if (dateTime != null) {
        final hour = dateTime.hour;
        final minute = dateTime.minute;

        // Only return time if it's not midnight (00:00)
        if (hour != 0 || minute != 0) {
          final ampm = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour % 12 == 0 ? 12 : hour % 12;
          final minuteStr = minute.toString().padLeft(2, '0');
          return '$displayHour:$minuteStr $ampm';
        }
      }
    } catch (e) {
      print('Error formatting date-time field: $e');
    }
    return null;
  }
}

// ✅ ENHANCED: Symptom Card Widget with better time handling
class _SymptomCard extends StatelessWidget {
  final String label;
  final String? time;
  final String? severity;
  final Color severityColor;
  final VoidCallback? onTap;

  const _SymptomCard({
    required this.label,
    this.time,
    this.severity,
    this.severityColor = Colors.deepPurple,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          margin: EdgeInsets.all(4),
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
            // ✅ ENHANCED: Add subtle border with severity color
            border: Border.all(color: severityColor.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ ENHANCED: Symptom name with severity indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Severity dot indicator
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: severityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // ✅ ENHANCED: Time display with better fallback
                  if (time != null && time!.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.teal),
                        SizedBox(width: 4),
                        Text(
                          time!,
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                  ] else ...[
                    // ✅ NEW: Show placeholder when no time available
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        SizedBox(width: 4),
                        Text(
                          'No time',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                  ],

                  // ✅ ENHANCED: Severity display
                  if (severity != null && severity!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: severityColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        severity!.toUpperCase(),
                        style: TextStyle(
                          color: severityColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
          height: 140,
          margin: EdgeInsets.all(4),
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon (if provided)
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                  SizedBox(height: 4),
                ],
                
                // Label text
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),
                
                // Date field (specialty for doctors)
                if (date != null && date!.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      date!,
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                ],
                
                // Time field (phone for doctors)
                if (time != null && time!.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      time!,
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
