import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/auth_service.dart'; // Import your existing auth service

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Helper method to check if user is signed in
  bool get _isSignedIn => authService.value.currentUser != null;
  
  // Helper method to get current user ID
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
      // Ensure user is authenticated
      if (!_isSignedIn) {
        throw Exception('User must be signed in to add tasks');
      }

      await _db.collection('tasks').add({
        'title': title.trim(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'todos': todos,
        'todosChecked': todosChecked,
        'userId': _currentUserId, // Add userId field
        'createdAt': FieldValue.serverTimestamp(), // Remove duplicate
      });
      print('Task added successfully');
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(
    String id, {
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
        throw Exception('User must be signed in to update tasks');
      }

      await _db.collection('tasks').doc(id).update({
        'title': title.trim(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'todos': todos,
        'todosChecked': todosChecked,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Task updated successfully');
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to delete tasks');
      }

      await _db.collection('tasks').doc(id).delete();
      print('Task deleted successfully');
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // FIXED: Now filters by userId to match Firestore security rules
  Stream<QuerySnapshot> getTasks() {
    try {
      // Ensure user is authenticated
      if (!_isSignedIn) {
        throw Exception('User must be signed in to view tasks');
      }

      return _db
          .collection('tasks')
          .where('userId', isEqualTo: _currentUserId) // Filter by current user
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting tasks stream: $e');
      rethrow;
    }
  }

  // Additional helper methods
  Future<List<DocumentSnapshot>> getTasksForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to view tasks');
      }

      QuerySnapshot snapshot = await _db
          .collection('tasks')
          .where('userId', isEqualTo: _currentUserId)
          .where('startDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('endDate', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('startDate')
          .get();

      return snapshot.docs;
    } catch (e) {
      print('Error getting tasks for date range: $e');
      rethrow;
    }
  }

  Future<void> toggleTodoItem(String taskId, int todoIndex, bool isChecked) async {
    try {
      if (!_isSignedIn) {
        throw Exception('User must be signed in to update tasks');
      }

      DocumentSnapshot doc = await _db.collection('tasks').doc(taskId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<bool> todosChecked = List<bool>.from(data['todosChecked'] ?? []);
        
        if (todoIndex < todosChecked.length) {
          todosChecked[todoIndex] = isChecked;
          
          await _db.collection('tasks').doc(taskId).update({
            'todosChecked': todosChecked,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error toggling todo item: $e');
      rethrow;
    }
  }

  // Test Firestore connection
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
}
