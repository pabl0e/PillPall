import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpall/views/global_homebar.dart';
import 'package:pillpall/services/task_service.dart';

class Task_Widget extends StatefulWidget {
  const Task_Widget({super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {
  DateTime _selectedDate = DateTime.now();
  final TaskService _taskService = TaskService();
  bool _isLoading = false;

  // Method to get tasks for selected date
  Stream<QuerySnapshot> _getTasksForDate(DateTime date) {
    String dateString = date.toIso8601String().split('T')[0];
    return _taskService.getTasksForDate(dateString);
  }

  Future<void> _toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> todos = List<String>.from(data['todos'] ?? []);
        List<bool> todosChecked = List.filled(todos.length, isCompleted);

        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(taskId)
            .update({
          'todosChecked': todosChecked,
          'isCompleted': isCompleted,
          'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  double _calculateTaskCompletionPercentage(Map<String, dynamic> taskData) {
    final todos = taskData['todos'] as List?;
    final todosChecked = taskData['todosChecked'] as List?;
    
    if (todos == null || todos.isEmpty) return 0.0;
    if (todosChecked == null) return 0.0;
    
    int completedCount = 0;
    for (int i = 0; i < todos.length && i < todosChecked.length; i++) {
      if (todosChecked[i] == true) {
        completedCount++;
      }
    }
    
    return completedCount / todos.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFDDED),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDDED),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.deepPurple[900],
            size: 28,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Back to Home',
        ),
        title: Text(
          'Tasks',
          style: TextStyle(
            color: Colors.deepPurple[900],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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
                      "Tasks for ${_monthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}",
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
                    "Your Tasks for ${_monthName(_selectedDate.month)} ${_selectedDate.day}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[900],
                    ),
                  ),
                ),
                // Tasks List filtered by selected date
                SizedBox(
                  height: 400,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getTasksForDate(_selectedDate),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Loading tasks for ${_monthName(_selectedDate.month)} ${_selectedDate.day}...',
                              ),
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
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Error loading tasks',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
                              Icon(
                                Icons.task_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No tasks for this date',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the + button to add tasks for ${_monthName(_selectedDate.month)} ${_selectedDate.day}',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      final tasks = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, i) {
                          final task = tasks[i];
                          return _buildTaskCard(task);
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
          onPressed: _isLoading
              ? null
              : () => _showAddTaskDialog(_selectedDate),
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
          tooltip:
              'Add Task for ${_monthName(_selectedDate.month)} ${_selectedDate.day}',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 3, // Assuming tasks is at index 3
        onTap: (index) {
          // Navigation is handled by the GlobalHomeBar itself
        },
      ),
    );
  }

  // Enhanced task card with completion tracking
  Widget _buildTaskCard(DocumentSnapshot task) {
    final taskId = task.id;
    final taskData = task.data() as Map<String, dynamic>;
    final completionPercentage = _calculateTaskCompletionPercentage(taskData);
    final isFullyCompleted = completionPercentage == 1.0;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header with completion indicator
            Row(
              children: [
                Icon(
                  isFullyCompleted ? Icons.task_alt : Icons.task_outlined,
                  color: isFullyCompleted ? Colors.green : Colors.deepPurple,
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    taskData['title'] ?? 'Untitled Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[900],
                      decoration: isFullyCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                // Completion percentage
                if (taskData['todos'] != null && (taskData['todos'] as List).isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFullyCompleted ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(completionPercentage * 100).round()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, taskId, taskData),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: isFullyCompleted
                          ? 'mark_incomplete'
                          : 'mark_complete',
                      child: Row(
                        children: [
                          Icon(
                            isFullyCompleted ? Icons.undo : Icons.check_circle,
                            color: isFullyCompleted ? Colors.orange : Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            isFullyCompleted
                                ? 'Mark Incomplete'
                                : 'Mark Complete',
                          ),
                        ],
                      ),
                    ),
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
              ],
            ),
            SizedBox(height: 12),

            // Progress bar (if task has todos)
            if (taskData['todos'] != null && (taskData['todos'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: LinearProgressIndicator(
                  value: completionPercentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFullyCompleted ? Colors.green : Colors.deepPurple,
                  ),
                ),
              ),

            // Task Time Info
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.teal, size: 18),
                SizedBox(width: 4),
                Text(
                  '${_formatTimeAMPM(taskData['startTime'])} - ${_formatTimeAMPM(taskData['endTime'])}',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            // Task Date Range (if different from selected date)
            if (_shouldShowDateRange(taskData))
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.orange, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '${_formatDateWord(taskData['startDate'])} - ${_formatDateWord(taskData['endDate'])}',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Todo List
            if (taskData['todos'] != null && (taskData['todos'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Todo Items:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  ...List.generate(
                    (taskData['todos'] as List).length,
                    (todoIndex) {
                      final todos = taskData['todos'] as List;
                      final todosChecked = taskData['todosChecked'] as List? ?? [];
                      final isChecked = todoIndex < todosChecked.length
                          ? todosChecked[todoIndex]
                          : false;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (value) {
                                _toggleTodoItem(
                                  taskId,
                                  todoIndex,
                                  value ?? false,
                                );
                              },
                              activeColor: Colors.deepPurple,
                            ),
                            Expanded(
                              child: Text(
                                todos[todoIndex].toString(),
                                style: TextStyle(
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: isChecked
                                      ? Colors.grey[600]
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDateRange(Map<String, dynamic> taskData) {
    final startDate = taskData['startDate'];
    final endDate = taskData['endDate'];
    if (startDate == null || endDate == null) return false;

    final startDateTime = DateTime.tryParse(startDate);
    final endDateTime = DateTime.tryParse(endDate);
    if (startDateTime == null || endDateTime == null) return false;

    // Show date range if task spans multiple days or is not on selected date
    return startDateTime.day != endDateTime.day ||
        startDateTime.month != endDateTime.month ||
        startDateTime.year != endDateTime.year ||
        startDateTime.day != _selectedDate.day ||
        startDateTime.month != _selectedDate.month ||
        startDateTime.year != _selectedDate.year;
  }

  Future<void> _toggleTodoItem(
    String taskId,
    int todoIndex,
    bool isChecked,
  ) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<bool> todosChecked = List<bool>.from(data['todosChecked'] ?? []);
        
        if (todoIndex < todosChecked.length) {
          todosChecked[todoIndex] = isChecked;
          
          await FirebaseFirestore.instance
              .collection('tasks')
              .doc(taskId)
              .update({
            'todosChecked': todosChecked,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error toggling todo item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update todo item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleMenuAction(
    String action,
    String taskId,
    Map<String, dynamic> taskData,
  ) async {
    switch (action) {
      case 'edit':
        await _showEditTaskDialog(taskId, taskData);
        break;
      case 'delete':
        await _showDeleteConfirmation(taskId);
        break;
      case 'mark_complete':
        try {
          DocumentSnapshot doc = await FirebaseFirestore.instance
              .collection('tasks')
              .doc(taskId)
              .get();

          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            List<String> todos = List<String>.from(data['todos'] ?? []);
            List<bool> todosChecked = List.filled(todos.length, true);

            await FirebaseFirestore.instance
                .collection('tasks')
                .doc(taskId)
                .update({
              'todosChecked': todosChecked,
              'isCompleted': true,
              'completedAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task marked as complete!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update task'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
      case 'mark_incomplete':
        try {
          DocumentSnapshot doc = await FirebaseFirestore.instance
              .collection('tasks')
              .doc(taskId)
              .get();

          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            List<String> todos = List<String>.from(data['todos'] ?? []);
            List<bool> todosChecked = List.filled(todos.length, false);

            await FirebaseFirestore.instance
                .collection('tasks')
                .doc(taskId)
                .update({
              'todosChecked': todosChecked,
              'isCompleted': false,
              'completedAt': null,
              'updatedAt': FieldValue.serverTimestamp(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task marked as incomplete'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update task'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
    }
  }

  Future<void> _showAddTaskDialog(DateTime preselectedDate) async {
    TextEditingController titleController = TextEditingController();
    DateTime startDate = preselectedDate;
    DateTime endDate = preselectedDate;
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(
      hour: TimeOfDay.now().hour + 1,
      minute: TimeOfDay.now().minute,
    );
    List<TextEditingController> todoControllers = [TextEditingController()];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Add Task for ${_monthName(startDate.month)} ${startDate.day}',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Start Date
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Start Date: ${startDate.toLocal().toString().split(' ')[0]}",
                          ),
                        ),
                        TextButton(
                          child: Text('Change'),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(DateTime.now().year - 1),
                              lastDate: DateTime(DateTime.now().year + 2),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                startDate = picked;
                                if (endDate.isBefore(startDate)) {
                                  endDate = startDate;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // End Date
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "End Date: ${endDate.toLocal().toString().split(' ')[0]}",
                          ),
                        ),
                        TextButton(
                          child: Text('Change'),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: startDate,
                              lastDate: DateTime(DateTime.now().year + 2),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                endDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // Start Time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Start Time: ${startTime.format(context)}",
                          ),
                        ),
                        TextButton(
                          child: Text('Pick'),
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                startTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // End Time
                    Row(
                      children: [
                        Expanded(
                          child: Text("End Time: ${endTime.format(context)}"),
                        ),
                        TextButton(
                          child: Text('Pick'),
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                endTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Todo Items
                    Text(
                      'Todo Items:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                    ...List.generate(todoControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: todoControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Todo ${index + 1}',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            if (todoControllers.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    todoControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),

                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          todoControllers.add(TextEditingController());
                        });
                      },
                      icon: Icon(Icons.add),
                      label: Text('Add Todo Item'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    for (var controller in todoControllers) {
                      controller.dispose();
                    }
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Add Task'),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter task title')),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      List<String> todos = todoControllers
                          .map((controller) => controller.text.trim())
                          .where((text) => text.isNotEmpty)
                          .toList();

                      await _taskService.addTask(
                        title: titleController.text.trim(),
                        startDate: startDate,
                        endDate: endDate,
                        startTime: startTime.format(context),
                        endTime: endTime.format(context),
                        todos: todos,
                        todosChecked: List.filled(todos.length, false),
                      );

                      for (var controller in todoControllers) {
                        controller.dispose();
                      }

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Task added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      print('Error adding task: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to add task. Please try again.',
                          ),
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

  Future<void> _showEditTaskDialog(
    String taskId,
    Map<String, dynamic> taskData,
  ) async {
    TextEditingController titleController = TextEditingController(
      text: taskData['title'],
    );
    DateTime startDate =
        DateTime.tryParse(taskData['startDate'] ?? '') ?? DateTime.now();
    DateTime endDate =
        DateTime.tryParse(taskData['endDate'] ?? '') ?? DateTime.now();

    TimeOfDay startTime;
    TimeOfDay endTime;

    try {
      final startTimeParts = (taskData['startTime'] ?? '00:00').split(':');
      startTime = TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      );

      final endTimeParts = (taskData['endTime'] ?? '00:00').split(':');
      endTime = TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      );
    } catch (_) {
      startTime = TimeOfDay.now();
      endTime = TimeOfDay(
        hour: TimeOfDay.now().hour + 1,
        minute: TimeOfDay.now().minute,
      );
    }

    List<String> existingTodos = List<String>.from(taskData['todos'] ?? []);
    List<TextEditingController> todoControllers = existingTodos
        .map((todo) => TextEditingController(text: todo))
        .toList();

    if (todoControllers.isEmpty) {
      todoControllers.add(TextEditingController());
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Start Date
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Start Date: ${startDate.toLocal().toString().split(' ')[0]}",
                          ),
                        ),
                        TextButton(
                          child: Text('Change'),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(DateTime.now().year - 1),
                              lastDate: DateTime(DateTime.now().year + 2),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                startDate = picked;
                                if (endDate.isBefore(startDate)) {
                                  endDate = startDate;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // End Date
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "End Date: ${endDate.toLocal().toString().split(' ')[0]}",
                          ),
                        ),
                        TextButton(
                          child: Text('Change'),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: startDate,
                              lastDate: DateTime(DateTime.now().year + 2),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                endDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // Start Time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Start Time: ${startTime.format(context)}",
                          ),
                        ),
                        TextButton(
                          child: Text('Pick'),
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                startTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // End Time
                    Row(
                      children: [
                        Expanded(
                          child: Text("End Time: ${endTime.format(context)}"),
                        ),
                        TextButton(
                          child: Text('Pick'),
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                endTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Todo Items
                    Text(
                      'Todo Items:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                    ...List.generate(todoControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: todoControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Todo ${index + 1}',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            if (todoControllers.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    todoControllers[index].dispose();
                                    todoControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),

                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          todoControllers.add(TextEditingController());
                        });
                      },
                      icon: Icon(Icons.add),
                      label: Text('Add Todo Item'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    for (var controller in todoControllers) {
                      controller.dispose();
                    }
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Save Changes'),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter task title')),
                      );
                      return;
                    }
                    try {
                      List<String> todos = todoControllers
                          .map((controller) => controller.text.trim())
                          .where((text) => text.isNotEmpty)
                          .toList();

                      List<bool> existingChecked = List<bool>.from(
                        taskData['todosChecked'] ?? [],
                      );
                      List<bool> todosChecked = List.generate(todos.length, (
                        index,
                      ) {
                        return index < existingChecked.length
                            ? existingChecked[index]
                            : false;
                      });

                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(taskId)
                          .update({
                        'title': titleController.text.trim(),
                        'startDate': startDate.toIso8601String(),
                        'endDate': endDate.toIso8601String(),
                        'startDateOnly': startDate.toIso8601String().split('T')[0],
                        'endDateOnly': endDate.toIso8601String().split('T')[0],
                        'startTime': startTime.format(context),
                        'endTime': endTime.format(context),
                        'todos': todos,
                        'todosChecked': todosChecked,
                        'updatedAt': FieldValue.serverTimestamp(),
                      });

                      for (var controller in todoControllers) {
                        controller.dispose();
                      }

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Task updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      print('Error updating task: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update task. Please try again.',
                          ),
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

  Future<void> _showDeleteConfirmation(String taskId) async {
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
      try {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(taskId)
            .delete();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting task: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
