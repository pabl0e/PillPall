import 'package:flutter/material.dart';
import 'package:pillpall/widget/global_homebar.dart';
import 'package:pillpall/services/task_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpall/models/task_model.dart';

class Task_Widget extends StatefulWidget {
  const Task_Widget({super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {
  DateTime _selectedDate = DateTime.now();
  final TaskService _taskService = TaskService();
  bool _isLoading = false;

  // Controllers for the add task dialog
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _todoControllers = [
    TextEditingController(),
  ];

  // Method to get tasks for selected date
  Stream<List<TaskModel>> _getTasksForDate(DateTime date) {
    String dateString = date.toIso8601String().split('T')[0];
    return _taskService.getTasksForDate(dateString);
  }

  void _toggleTodoItem(String taskId, int todoIndex, bool isCompleted) {
    _taskService.toggleTodoItem(taskId, todoIndex, isCompleted);
  }

  void _toggleTaskCompletion(String taskId, bool isCompleted) {
    _taskService.toggleTaskCompletion(taskId, isCompleted);
  }

  void _addTask(TaskModel task) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _taskService.addTask(task);
    } catch (e) {
      print('Error adding task: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateTask(TaskModel task) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _taskService.updateTask(task);
    } catch (e) {
      print('Error updating task: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  child: StreamBuilder<List<TaskModel>>(
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

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
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

                      final tasks = snapshot.data!;
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
  Widget _buildTaskCard(TaskModel task) {
    final completionPercentage = task.todos.isNotEmpty
        ? task.todos.where((todo) => todo.isCompleted).length /
              task.todos.length
        : 0.0;
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
                    task.title,
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
                if (task.todos.isNotEmpty)
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
                  onSelected: (value) => _handleMenuAction(value, task),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: isFullyCompleted
                          ? 'mark_incomplete'
                          : 'mark_complete',
                      child: Row(
                        children: [
                          Icon(
                            isFullyCompleted ? Icons.undo : Icons.check_circle,
                            color: isFullyCompleted
                                ? Colors.orange
                                : Colors.green,
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
            if (task.todos.isNotEmpty)
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

            // Todo List
            if (task.todos.isNotEmpty)
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
                  ...task.todos.map((todo) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: todo.isCompleted,
                            onChanged: (value) {
                              _taskService.toggleTodoItem(
                                task.id,
                                task.todos.indexOf(todo),
                                value ?? false,
                              );
                            },
                            activeColor: Colors.deepPurple,
                          ),
                          Expanded(
                            child: Text(
                              todo.description,
                              style: TextStyle(
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: todo.isCompleted
                                    ? Colors.grey[600]
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(String action, TaskModel task) async {
    switch (action) {
      case 'edit':
        await _showEditTaskDialog(task.id, {
          'title': task.title,
          'date': task.date,
          'todos': task.todos.map((todo) => todo.description).toList(),
        });
        break;
      case 'delete':
        await _showDeleteConfirmation(task.id);
        break;
      case 'mark_complete':
        try {
          await _taskService.toggleTaskCompletion(task.id, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task marked as complete!'),
              backgroundColor: Colors.green,
            ),
          );
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
          await _taskService.toggleTaskCompletion(task.id, false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task marked as incomplete'),
              backgroundColor: Colors.orange,
            ),
          );
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

  void _showAddTaskDialog(DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              // Add todo fields dynamically
              ..._todoControllers.map(
                (controller) => TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: 'Todo Item'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final task = TaskModel(
                    id: '', // Firestore will generate this
                    userId: '', // Set this to the current user ID
                    date: selectedDate.toIso8601String().split('T')[0],
                    title: _titleController.text.trim(),
                    isCompleted: false,
                    todos: _todoControllers
                        .map(
                          (controller) => TodoItem(
                            isCompleted: false,
                            description: controller.text.trim(),
                          ),
                        )
                        .toList(),
                  );
                  _addTask(task);
                  Navigator.pop(context);
                },
                child: Text('Add Task'),
              ),
            ],
          ),
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
                      final updatedTask = TaskModel(
                        id: taskId,
                        userId: '', // Set to current user ID
                        date: _selectedDate.toIso8601String().split('T')[0],
                        title: titleController.text.trim(),
                        isCompleted: false, // Or keep previous value if needed
                        todos: todoControllers
                            .map(
                              (controller) => TodoItem(
                                isCompleted: false,
                                description: controller.text.trim(),
                              ),
                            )
                            .toList(),
                      );
                      await _taskService.updateTask(updatedTask);
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
        await _taskService.deleteTask(taskId);
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
