import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

/// Handles all Firestore CRUD operations for tasks.
/// Every method here operates only on the tasks belonging to
/// the currently authenticated user (via userId).
class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _tasksRef =
      FirebaseFirestore.instance.collection('tasks');

  /// Streams all tasks belonging to [userId], ordered by due date.
  Stream<List<TaskModel>> streamTasks(String userId) {
    return _tasksRef
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Creates a new task document.
  Future<void> createTask(TaskModel task) async {
    await _tasksRef.add(task.toMap());
  }

  /// Updates an existing task document.
  Future<void> updateTask(TaskModel task) async {
    await _tasksRef.doc(task.id).update(task.toMap());
  }

  /// Deletes a task document.
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  /// Toggles a task's completed status.
  Future<void> setCompleted(String taskId, bool completed) async {
    await _tasksRef.doc(taskId).update({'completed': completed});
  }
}
