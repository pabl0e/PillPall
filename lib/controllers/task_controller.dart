import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/services/task_service.dart';
import 'package:pillpall/services/alarm_service.dart';

class TaskController extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  DateTime _selectedDate = DateTime.now();

  // Getters
  DateTime get selectedDate => _selectedDate;

  // Update selected date
  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Get tasks for selected date
  Stream<QuerySnapshot> getTasksForDate(DateTime date) {
    String dateString = date.toIso8601String().split('T')[0];
    return _taskService.getTasksForDate(dateString);
  }

  // Calculate task completion percentage
  double calculateTaskCompletionPercentage(Map<String, dynamic> taskData) {
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

  // Separate tasks into active and completed
  Map<String, List<DocumentSnapshot>> separateTasks(List<DocumentSnapshot> allTasks) {
    final activeTasks = allTasks.where((task) {
      final taskData = task.data() as Map<String, dynamic>;
      // A task is active if it's not explicitly marked complete AND not at 100% progress
      final isExplicitlyCompleted = taskData['isCompleted'] == true;
      final completionPercentage = calculateTaskCompletionPercentage(taskData);
      return !isExplicitlyCompleted && completionPercentage < 1.0;
    }).toList();
    
    final completedTasks = allTasks.where((task) {
      final taskData = task.data() as Map<String, dynamic>;
      // A task is completed if it's explicitly marked complete OR at 100% progress
      final isExplicitlyCompleted = taskData['isCompleted'] == true;
      final completionPercentage = calculateTaskCompletionPercentage(taskData);
      return isExplicitlyCompleted || completionPercentage >= 1.0;
    }).toList();

    return {
      'active': activeTasks,
      'completed': completedTasks,
    };
  }

  // Toggle individual todo item
  Future<bool> toggleTodoItem(String taskId, int todoIndex, bool isChecked) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<bool> todosChecked = List<bool>.from(data['todosChecked'] ?? []);
        List<String> todos = List<String>.from(data['todos'] ?? []);
        
        if (todoIndex < todosChecked.length) {
          todosChecked[todoIndex] = isChecked;
          
          // Check if all todos are now completed
          bool allTodosCompleted = todosChecked.every((checked) => checked == true);
          
          // Update the task with new todo status and completion if needed
          Map<String, dynamic> updateData = {
            'todosChecked': todosChecked,
            'updatedAt': FieldValue.serverTimestamp(),
          };
          
          // If all todos are completed, mark the task as complete
          if (allTodosCompleted && todos.isNotEmpty) {
            updateData['isCompleted'] = true;
            updateData['completedAt'] = FieldValue.serverTimestamp();
            print('✅ Task automatically marked as complete: all todos finished');
          }
          // If not all todos are completed but task was previously marked complete, unmark it
          else if (!allTodosCompleted && data['isCompleted'] == true) {
            updateData['isCompleted'] = false;
            updateData['completedAt'] = null;
            print('🔄 Task unmarked as complete: not all todos finished');
          }
          
          await FirebaseFirestore.instance
              .collection('tasks')
              .doc(taskId)
              .update(updateData);
          
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error toggling todo item: $e');
      return false;
    }
  }

  // Trigger task alarm
  void triggerTaskAlarm(BuildContext context, String taskId, Map<String, dynamic> taskData) {
    AlarmService().triggerTaskAlarm(
      context,
      taskId: taskId,
      taskData: taskData,
    );
  }

  // Mark task as complete/incomplete
  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted) async {
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

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling task completion: $e');
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .delete();
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Add new task
  Future<bool> addTask({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    required List<String> todos,
    required List<bool> todosChecked,
  }) async {
    try {
      await _taskService.addTask(
        title: title,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        todos: todos,
        todosChecked: todosChecked,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding task: $e');
      return false;
    }
  }

  // Update task
  Future<bool> updateTask(
    String taskId,
    String title,
    DateTime startDate,
    DateTime endDate,
    String startTime,
    String endTime,
    List<String> todos,
    List<bool> todosChecked,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .update({
        'title': title,
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
        'startTime': startTime,
        'endTime': endTime,
        'todos': todos,
        'todosChecked': todosChecked,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  // Check if task should show date range
  bool shouldShowDateRange(Map<String, dynamic> taskData, DateTime selectedDate) {
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
        startDateTime.day != selectedDate.day ||
        startDateTime.month != selectedDate.month ||
        startDateTime.year != selectedDate.year;
  }

  // Format time for database
  String formatTimeForDatabase(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Format time for display (AM/PM)
  String formatTimeAMPM(String? time) {
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

  // Format date for display
  String formatDateWord(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return "${months[date.month]} ${date.day}, ${date.year}";
  }

  // Format completed date
  String formatCompletedDate(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays == 0) {
          if (difference.inHours == 0) {
            return '${difference.inMinutes}m ago';
          }
          return '${difference.inHours}h ago';
        } else if (difference.inDays == 1) {
          return 'Yesterday';
        } else {
          return '${difference.inDays}d ago';
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  // Get month name
  String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }
}
