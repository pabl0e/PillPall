import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Task_Widget(),
    debugShowCheckedModeBanner: false,
  ));
}

class Task_Widget extends StatefulWidget {
  const Task_Widget({super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {
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
                // Paracetamol Card
                Container(
                  width: double.infinity,
                  height: 100,
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
                        Item1(),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Paracetamol',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '5mg',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.deepPurple[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  width: 90,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFDDED),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.access_time, size: 15, color: Colors.deepPurple[900]),
                                      SizedBox(width: 5),
                                      Text(
                                        '8:00 AM',
                                        style: TextStyle(
                                          fontSize: 14,
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
                  height: 100,
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
                        Item2(),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Antihistamine',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '10mg',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.deepPurple[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  width: 90,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFDDED),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.access_time, size: 15, color: Colors.deepPurple[900]),
                                      SizedBox(width: 5),
                                      Text(
                                        '9:00 AM',
                                        style: TextStyle(
                                          fontSize: 14,
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
      floatingActionButton: FloatingActionButton(
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
                            decoration: InputDecoration(labelText: 'Medication Name'),
                          ),
                          TextField(
                            controller: doseController,
                            decoration: InputDecoration(labelText: 'Dosage'),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text("Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
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
                        child: Text('Add'),
                        onPressed: () {
                          // Handle add logic here
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
        child: Icon(Icons.add, color: Colors.white), // <-- Set icon color to white
        backgroundColor: Colors.deepPurple,
        tooltip: 'Add Medication',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 15), // Only bottom margin for spacing
        width: double.infinity, // Ensure full width
        decoration: BoxDecoration(
          color: Colors.white,
          //borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Only top corners rounded
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.deepPurple, size: 30),
                onPressed: () {},
                tooltip: 'Home',
              ),
              IconButton(
                icon: Icon(Icons.people, color: Colors.deepPurple, size: 30),
                onPressed: () {},
                tooltip: 'People',
              ),
              IconButton(
                icon: Icon(Icons.medication, color: Colors.deepPurple, size: 30),
                onPressed: () {},
                tooltip: 'Pills',
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.deepPurple, size: 30),
                onPressed: () {},
                tooltip: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

Widget Item1(){
  return Container(
    height: 90,
    width: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      image:DecorationImage(
        image: AssetImage('assets/paracetamol.png'),
      ),
    ),
  );
}

Widget Item2(){
  return Container(
    height: 90,
    width: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      image:DecorationImage(
        image: AssetImage('assets/antihistamine.png'),
      ),
    ),
  );
}