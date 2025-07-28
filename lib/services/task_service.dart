import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpall/services/auth_service.dart';
import 'package:pillpall/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool get _isSignedIn => authService.value.currentUser != null;
  String? get _currentUserId => authService.value.currentUser?.uid;

  Future<void> addTask({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    required List<String> todos,
    required List<bool> todosChecked,
  }) async {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to add tasks');
      }

      await _db.collection('tasks').add({
        'title': title.trim(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'startDateOnly': startDate.toIso8601String().split('T')[0],
        'endDateOnly': endDate.toIso8601String().split('T')[0],
        'startTime': startTime,
        'endTime': endTime,
        'todos': todos,
        'todosChecked': todosChecked,
        'userId': _currentUserId,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Task added successfully');
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getTasksForDate(String dateString) {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to view tasks');
      }

      return _db
          .collection('tasks')
          .where('userId', isEqualTo: _currentUserId)
          .where('startDateOnly', isLessThanOrEqualTo: dateString)
          .where('endDateOnly', isGreaterThanOrEqualTo: dateString)
          .orderBy('startTime')
          .snapshots();
    } catch (e) {
      print('Error getting tasks for date: $e');
      rethrow;
    }
  }

  Stream<List<TaskModel>> getTasksForDateModel(String dateString) {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to view tasks');
    }
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: _currentUserId)
        .where('date', isEqualTo: dateString)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addTask(TaskModel task) async {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to add tasks');
    }
    await _db.collection('tasks').add(task.toFirestore());
  }

  Stream<List<TaskModel>> getTasks() {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to view tasks');
    }
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateTask(TaskModel task) async {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to update tasks');
    }
    await _db.collection('tasks').doc(task.id).update(task.toFirestore());
  }

  Future<void> deleteTask(String id) async {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to delete tasks');
    }
    await _db.collection('tasks').doc(id).delete();
  }

  Future<double> getTaskCompletionPercentage(String dateString) async {
    if (!_isSignedIn) {
      throw Exception(
        'User must be signed in to view task completion percentage',
      );
    }

    final snapshot = await _db
        .collection('tasks')
        .where('userId', isEqualTo: _currentUserId)
        .where('date', isEqualTo: dateString)
        .get();

    final tasks = snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc.data(), doc.id))
        .toList();
    if (tasks.isEmpty) return 0.0;

    final completedTasks = tasks
        .where((task) => task.todos.every((todo) => todo.isCompleted))
        .length;
    return completedTasks / tasks.length;
  }

  Future<void> toggleTodoItem(
    String taskId,
    int todoIndex,
    bool isCompleted,
  ) async {
    if (!_isSignedIn) {
      throw Exception('User must be signed in to toggle todo items');
    }

    final taskDoc = await _db.collection('tasks').doc(taskId).get();
    if (!taskDoc.exists) {
      throw Exception('Task not found');
    }

    final task = TaskModel.fromFirestore(taskDoc.data()!, taskDoc.id);
    task.todos[todoIndex].isCompleted = isCompleted;

    await _db.collection('tasks').doc(taskId).update(task.toFirestore());
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to update tasks');
      }

      DocumentSnapshot doc = await _db.collection('tasks').doc(taskId).get();

      if (!doc.exists) {
        throw Exception('Task not found');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data['userId'] != _currentUserId) {
        throw Exception('Unauthorized to modify this task');
      }

      List<String> todos = List<String>.from(data['todos'] ?? []);
      List<bool> todosChecked = List.filled(todos.length, isCompleted);

      await _db.collection('tasks').doc(taskId).update({
        'todosChecked': todosChecked,
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Task completion toggled successfully');
    } catch (e) {
      print('Error toggling task completion: $e');
      rethrow;
    }
  }

  // BONUS METHOD: Get tasks by date range
  Future<List<DocumentSnapshot>> getTasksForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to view tasks');
      }

      String startDateString = startDate.toIso8601String().split('T')[0];
      String endDateString = endDate.toIso8601String().split('T')[0];

      QuerySnapshot snapshot = await _db
          .collection('tasks')
          .where('userId', isEqualTo: _currentUserId)
          .where('startDateOnly', isLessThanOrEqualTo: endDateString)
          .where('endDateOnly', isGreaterThanOrEqualTo: startDateString)
          .orderBy('startDateOnly')
          .orderBy('startTime')
          .get();

      return snapshot.docs;
    } catch (e) {
      print('Error getting tasks for date range: $e');
      rethrow;
    }
  }

  // BONUS METHOD: Get task statistics
  Future<Map<String, int>> getTaskStatistics() async {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to view tasks');
      }

      QuerySnapshot snapshot = await _db
          .collection('tasks')
          .where('userId', isEqualTo: _currentUserId)
          .get();

      int totalTasks = snapshot.docs.length;
      int completedTasks = 0;
      int totalTodos = 0;
      int completedTodos = 0;

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['isCompleted'] == true) {
          completedTasks++;
        }

        List<String> todos = List<String>.from(data['todos'] ?? []);
        List<bool> todosChecked = List<bool>.from(data['todosChecked'] ?? []);

        totalTodos += todos.length;

        for (int i = 0; i < todos.length && i < todosChecked.length; i++) {
          if (todosChecked[i]) {
            completedTodos++;
          }
        }
      }

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'pendingTasks': totalTasks - completedTasks,
        'totalTodos': totalTodos,
        'completedTodos': completedTodos,
        'pendingTodos': totalTodos - completedTodos,
      };
    } catch (e) {
      print('Error getting task statistics: $e');
      rethrow;
    }
  }

  // BONUS METHOD: Test Firestore connection
  Future<bool> testConnection() async {
    try {
      await _db.collection('tasks').limit(1).get();
      print('Tasks Firestore connection successful');
      return true;
    } catch (e) {
      print('Tasks Firestore connection failed: $e');
      return false;
    }
  }

  // BONUS METHOD: Get overdue tasks
  Stream<QuerySnapshot> getOverdueTasks() {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to view tasks');
      }

      String today = DateTime.now().toIso8601String().split('T')[0];

      return _db
          .collection('tasks')
          .where('userId', isEqualTo: _currentUserId)
          .where('endDateOnly', isLessThan: today)
          .where('isCompleted', isEqualTo: false)
          .orderBy('endDateOnly')
          .snapshots();
    } catch (e) {
      print('Error getting overdue tasks: $e');
      rethrow;
    }
  }

  // BONUS METHOD: Get today's tasks
  Stream<QuerySnapshot> getTodaysTasks() {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to view tasks');
      }

      String today = DateTime.now().toIso8601String().split('T')[0];

      return _db
          .collection('tasks')
          .where('userId', isEqualTo: _currentUserId)
          .where('startDateOnly', isLessThanOrEqualTo: today)
          .where('endDateOnly', isGreaterThanOrEqualTo: today)
          .orderBy('startTime')
          .snapshots();
    } catch (e) {
      print('Error getting today\'s tasks: $e');
      rethrow;
    }
  }
}
}
