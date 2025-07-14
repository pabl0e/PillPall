import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpall/auth_service.dart';
import 'package:pillpall/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool get _isSignedIn => authService.value.currentUser != null;
  String? get _currentUserId => authService.value.currentUser?.uid;

  Stream<List<TaskModel>> getTasksForDate(String dateString) {
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
    if (!_isSignedIn) {
      throw Exception('User must be signed in to toggle task completion');
    }

    await _db.collection('tasks').doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }
}
