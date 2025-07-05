import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addTask({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime, // <-- String instead of TimeOfDay
    required String endTime,
    required List<String> todos,
    required List<bool> todosChecked,
  }) async {
    await _db.collection('tasks').add({
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'todos': todos,
      'todosChecked': todosChecked,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
    await _db.collection('tasks').doc(id).update({
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'todos': todos,
      'todosChecked': todosChecked,
    });
  }

  Future<void> deleteTask(String id) async {
    await _db.collection('tasks').doc(id).delete();
  }

  Stream<QuerySnapshot> getTasks() {
    return _db.collection('tasks').orderBy('createdAt', descending: true).snapshots();
  }
}