import 'package:flutter/material.dart';
import 'package:pillpall/widget/global_homebar.dart';

void main() {
  runApp(MaterialApp(home: Task_Widget(), debugShowCheckedModeBanner: false));
}

class Task_Widget extends StatefulWidget {
  const Task_Widget({super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {
  DateTime _selectedDate = DateTime.now();
  bool isDone1 = false;
  bool isDone2 = false;

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
                Text(
                  "Tasks for ${_monthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[900],
                  ),
                ),
                SizedBox(height: 10),
                // Paracetamol Card
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        //SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isDone1,
                                  onChanged: (value) {
                                    setState(() {
                                      isDone1 = !isDone1;
                                    });
                                  },
                                ),
                                Text(
                                  'Drink Water ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),

                                SizedBox(width: 8),
                                Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.deepPurple[700],
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  width: 85,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFDDED),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: Colors.deepPurple[900],
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        '8:00 AM',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.deepPurple[900],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Antihistamine Card
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        //SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isDone2,
                                  onChanged: (value) {
                                    setState(() {
                                      isDone2 = !isDone2;
                                    });
                                  },
                                ),
                                Text(
                                  'Take Antibiotic',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Tomorrow',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.deepPurple[700],
                                  ),
                                ),
                              ],
                            ),
                            //SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  width: 85,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFDDED),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: Colors.deepPurple[900],
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '9:00 PM',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.deepPurple[900],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32.0), // Raises the FAB above the nav bar
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                TextEditingController checkboxController =
                    TextEditingController();
                TextEditingController itemController = TextEditingController();
                DateTime startDate = DateTime.now();
                DateTime endDate = DateTime.now();
                TimeOfDay startTime = TimeOfDay.now();
                TimeOfDay endTime = TimeOfDay.now();
                List<String> todos = [];
                List<bool> todosChecked = [];
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: EdgeInsets.all(20),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Calendar Icon
                            Icon(
                              Icons.calendar_month,
                              size: 32,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(height: 10),
                            // Start/End Date Row
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: startDate,
                                        firstDate: DateTime(
                                          DateTime.now().year - 1,
                                        ),
                                        lastDate: DateTime(
                                          DateTime.now().year + 2,
                                        ),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          startDate = picked;
                                          if (endDate.isBefore(startDate))
                                            endDate = startDate;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: endDate.isBefore(startDate)
                                            ? startDate
                                            : endDate,
                                        firstDate: startDate,
                                        lastDate: DateTime(
                                          DateTime.now().year + 2,
                                        ),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          endDate = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Start/End Time Row with clock icon in the middle and slightly higher
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Start Time
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      TimeOfDay? picked = await showTimePicker(
                                        context: context,
                                        initialTime: startTime,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          startTime = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Start: ${startTime.format(context)}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Clock icon in the middle, slightly higher
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 6,
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                // End Time
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      TimeOfDay? picked = await showTimePicker(
                                        context: context,
                                        initialTime: endTime,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          endTime = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "End: ${endTime.format(context)}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 24),
                            // To Do Section
                            Text(
                              "To Do",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepPurple[900],
                              ),
                            ),
                            SizedBox(height: 10),
                            // Add checkbox item
                            Row(
                              children: [
                                Checkbox(value: false, onChanged: null),
                                Expanded(
                                  child: TextField(
                                    controller: checkboxController,
                                    decoration: InputDecoration(
                                      hintText: "Add checkbox...",
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (val) {
                                      if (val.trim().isNotEmpty) {
                                        setState(() {
                                          todos.add(val.trim());
                                          todosChecked.add(false);
                                          checkboxController.clear();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // List of added todos
                            ...List.generate(
                              todos.length,
                              (i) => Row(
                                children: [
                                  Checkbox(
                                    value: todosChecked[i],
                                    onChanged: (val) {
                                      setState(() {
                                        todosChecked[i] = val ?? false;
                                      });
                                    },
                                  ),
                                  Expanded(child: Text(todos[i])),
                                ],
                              ),
                            ),
                            // Add item row
                            Row(
                              children: [
                                Icon(Icons.add, color: Colors.deepPurple),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: itemController,
                                    decoration: InputDecoration(
                                      hintText: "Add item...",
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (val) {
                                      if (val.trim().isNotEmpty) {
                                        setState(() {
                                          todos.add(val.trim());
                                          todosChecked.add(false);
                                          itemController.clear();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF69B4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  "SUBMIT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                onPressed: () {
                                  // Handle submit logic here
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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
        selectedIndex: 2, // Pills/Medication page
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
