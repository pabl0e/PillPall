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
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "- Your medication companion",
                      style: TextStyle(
                        fontSize: 16,
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
                        // Action to add tasks
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