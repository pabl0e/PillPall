import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pillpall/widget/global_homebar.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();

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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                        showDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController checkboxController = TextEditingController();
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
                                                    firstDate: DateTime(DateTime.now().year - 1),
                                                    lastDate: DateTime(DateTime.now().year + 2),
                                                  );
                                                  if (picked != null) {
                                                    setState(() {
                                                      startDate = picked;
                                                      if (endDate.isBefore(startDate)) endDate = startDate;
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF5F5F5),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
                                                      style: TextStyle(fontSize: 14, color: Colors.black87),
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
                                                    initialDate: endDate.isBefore(startDate) ? startDate : endDate,
                                                    firstDate: startDate,
                                                    lastDate: DateTime(DateTime.now().year + 2),
                                                  );
                                                  if (picked != null) {
                                                    setState(() {
                                                      endDate = picked;
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF5F5F5),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
                                                      style: TextStyle(fontSize: 14, color: Colors.black87),
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
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF5F5F5),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Start: ${startTime.format(context)}",
                                                      style: TextStyle(fontSize: 14, color: Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10, top: 6),
                                              child: Icon(Icons.access_time, color: Colors.deepPurple),
                                            ),
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
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF5F5F5),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "End: ${endTime.format(context)}",
                                                      style: TextStyle(fontSize: 14, color: Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(height: 24),
                                        Text(
                                          "To Do",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.deepPurple[900],
                                          ),
                                        ),
                                        SizedBox(height: 10),
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
                    ),
                    SizedBox(width: 16),
                    // Empty Card 1
                    _SquareTaskCard(),
                    SizedBox(width: 16),
                    // Empty Card 2
                    _SquareTaskCard(),
                  ],
                ),
                SizedBox(height: 20),
                // My daily insights Section
                Text(
                  "My daily insights",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                      // Action to log symptoms
                      },
                    ),
                    SizedBox(width: 16),
                    _SquareTaskCard(),
                    SizedBox(width: 16),
                    _SquareTaskCard(),
                  ],
                ),
                SizedBox(height: 20),
                // Your Doctor's Contact Details
                Text(
                  "Your Doctor's Contact Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _SquareTaskCard(
                      label: "Add Doctor",
                      icon: Icons.add,
                      onTap: () {
                        // Action to add doctor
                      },
                    ),
                    SizedBox(width: 16),
                    _SquareTaskCard(),
                    SizedBox(width: 16),
                    _SquareTaskCard(),
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

  Widget _buildReminderTile(String medication, String dosage, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFDDED),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 4),
              Text(
                dosage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple[700],
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add this widget below your _HomePageState class (outside of it):
class _SquareTaskCard extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _SquareTaskCard({
    this.label = "",
    this.icon,
    this.onTap,
    super.key,
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
            child: icon != null
                ? Column(
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
                      SizedBox(height: 12),
                      Icon(icon, size: 32, color: Colors.black87),
                    ],
                  )
                : Container(),
          ),
        ),
      ),
    );
  }
}