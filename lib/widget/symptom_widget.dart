import 'package:flutter/material.dart';
import 'package:pillpall/widget/global_homebar.dart';

class SymptomWidget extends StatefulWidget {
  const SymptomWidget({super.key});

  @override
  State<SymptomWidget> createState() => _SymptomWidgetState();
}

class _SymptomWidgetState extends State<SymptomWidget> {
  DateTime _selectedDate = DateTime.now();

  final List<SymptomEntry> symptomEntries = [
    SymptomEntry(
      text: "Lorem Ipsum is simply dummy text of the print...",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SymptomEntry(
      text: "Lorem Ipsum is simply dummy text of the print...",
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFDDED),
      appBar: AppBar(
        title: const Text(
          'Symptom Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFFFDDED),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 18),

            // Calendar Section
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16),
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

            const SizedBox(height: 16),

            // Symptoms Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...symptomEntries.map((entry) => _buildSymptomEntry(entry)),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 1, // Symptom page
        onTap: (index) {
          // Navigation is handled by the GlobalHomeBar itself
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: FloatingActionButton(
          onPressed: () {
            // Add symptom functionality
            _showAddSymptomDialog();
          },
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.deepPurple,
          tooltip: 'Add Symptom',
        ),
      ),
    );
  }

  void _showAddSymptomDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController symptomController = TextEditingController();
        return AlertDialog(
          title: Text('Add Symptom'),
          content: TextField(
            controller: symptomController,
            decoration: InputDecoration(
              labelText: 'Describe your symptoms',
              hintText: 'e.g., Headache, Nausea, etc.',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                if (symptomController.text.isNotEmpty) {
                  setState(() {
                    symptomEntries.add(
                      SymptomEntry(
                        text: symptomController.text,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSymptomEntry(SymptomEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SymptomEntry {
  final String text;
  final DateTime timestamp;

  SymptomEntry({required this.text, required this.timestamp});
}
