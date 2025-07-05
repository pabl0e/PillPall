import 'package:flutter/material.dart';
import 'package:pillpall/services/task_service.dart';
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
  final TaskService _taskService = TaskService();

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
                  "Tasks",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[900],
                  ),
                ),
                SizedBox(height: 10),
                // Replace the hardcoded task cards with this:
                SizedBox(
                  height: 300,
                  child: StreamBuilder(
                    stream: _taskService.getTasks(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No tasks yet.'));
                      }
                      final tasks = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, i) {
                          final task = tasks[i];
                          final taskId = task.id;
                          final data = task.data() as Map<String, dynamic>;
                          final todos = List<String>.from(data['todos'] ?? []);
                          final todosChecked = List<bool>.from(data['todosChecked'] ?? []);
                          final isWholeDay = (data['startTime'] == "" && data['endTime'] == "");
                          return Card(
                            child: ListTile(
                              leading: Checkbox(
                                value: false, // Always unchecked when shown
                                onChanged: (val) async {
                                  if (val == true) {
                                    await _taskService.deleteTask(taskId);
                                  }
                                },
                              ),
                              title: Text(data['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isWholeDay)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.event_available, color: Colors.orange, size: 18),
                                          SizedBox(width: 4),
                                          Text(
                                            "Whole Day Task",
                                            style: TextStyle(
                                              color: Colors.orange[800],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Text(
                                    'Start: ${_formatDateWord(data['startDate'])} ${_formatTimeAMPM(data['startTime'])}',
                                  ),
                                  Text(
                                    'End: ${_formatDateWord(data['endDate'])} ${_formatTimeAMPM(data['endTime'])}',
                                  ),
                                  ...List.generate(todos.length, (j) => Row(
                                    children: [
                                      Expanded(child: Text(todos[j])),
                                    ],
                                  )),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    TextEditingController titleController = TextEditingController(text: data['title'] ?? '');
                                    TextEditingController itemController = TextEditingController();
                                    DateTime startDate = DateTime.tryParse(data['startDate'] ?? '') ?? DateTime.now();
                                    DateTime endDate = DateTime.tryParse(data['endDate'] ?? '') ?? DateTime.now();
                                    TimeOfDay startTime = _parseTimeOfDay(data['startTime']);
                                    TimeOfDay endTime = _parseTimeOfDay(data['endTime']);
                                    List<String> todos = List<String>.from(data['todos'] ?? []);
                                    List<bool> todosChecked = List<bool>.from(data['todosChecked'] ?? []);

                                    await showDialog(
                                      context: context,
                                      builder: (context) {
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
                                                    Icon(Icons.calendar_month, size: 32, color: Colors.deepPurple),
                                                    SizedBox(height: 10),
                                                    TextField(
                                                      controller: titleController,
                                                      decoration: InputDecoration(
                                                        labelText: "Task Title",
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
                                                    SizedBox(height: 16),
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
                                                    SizedBox(height: 16),
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
                                                    ...List.generate(
                                                      todos.length,
                                                      (i) => Row(
                                                        children: [
                                                          Expanded(child: Text(todos[i])),
                                                        ],
                                                      ),
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
                                                          "SAVE",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            letterSpacing: 1.2,
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          await _taskService.updateTask(
                                                            taskId,
                                                            title: titleController.text,
                                                            startDate: startDate,
                                                            endDate: endDate,
                                                            startTime: startTime.format(context),
                                                            endTime: endTime.format(context),
                                                            todos: todos,
                                                            todosChecked: todosChecked,
                                                          );
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
                                  } else if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Delete Task'),
                                        content: Text('Are you sure you want to delete this task?'),
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
                                      await _taskService.deleteTask(taskId);
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
        padding: const EdgeInsets.only(
          bottom: 32.0,
        ), // Raises the FAB above the nav bar
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                TextEditingController titleController = TextEditingController();
                TextEditingController itemController = TextEditingController();
                DateTime startDate = DateTime.now();
                DateTime endDate = DateTime.now();
                TimeOfDay startTime = TimeOfDay.now();
                TimeOfDay endTime = TimeOfDay.now();
                List<String> todos = [];
                List<bool> todosChecked = [];
                bool isWholeDay = false; // <-- Add this variable

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
                            // Task Title
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: "Task Title",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Whole Day Checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: isWholeDay,
                                  onChanged: (val) {
                                    setState(() {
                                      isWholeDay = val ?? false;
                                    });
                                  },
                                ),
                                Text("Whole Day Task"),
                              ],
                            ),
                            SizedBox(height: 8),
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
                                        lastDate: DateTime(DateTime.now().year + 2),
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
                            // Only show time pickers if not whole day
                            if (!isWholeDay)
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
                            SizedBox(height: 16),
                            // Add item row (for subtasks)
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
                            // List of added todos (subtasks)
                            ...List.generate(
                              todos.length,
                              (i) => Row(
                                children: [
                                  Expanded(child: Text(todos[i])),
                                ],
                              ),
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
                                onPressed: () async {
                                  await _taskService.addTask(
                                    title: titleController.text,
                                    startDate: startDate,
                                    endDate: endDate,
                                    startTime: isWholeDay ? "" : startTime.format(context),
                                    endTime: isWholeDay ? "" : endTime.format(context),
                                    todos: todos,
                                    todosChecked: todosChecked,
                                  );
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
        selectedIndex: 3, // Tasks page (was 2, now 3)
        onTap: (index) {
          // Navigation is handled by the GlobalHomeBar itself
        },
      ),
    );
  }

  String _formatDateWord(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    // Example: July 6, 2025
    return "${_monthName(date.month)} ${date.day}, ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      '', // 0 index not used
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  TimeOfDay _parseTimeOfDay(String? time) {
    if (time == null) return TimeOfDay(hour: 0, minute: 0);
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
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
