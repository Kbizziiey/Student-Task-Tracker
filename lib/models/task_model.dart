import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single student task stored in Firestore
/// at tasks/{taskId}.
class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  final bool completed;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.completed,
    required this.createdAt,
  });

  /// Builds a TaskModel from a Firestore document.
  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      completed: map['completed'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converts this TaskModel into a map for writing to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'subject': subject,
      'dueDate': Timestamp.fromDate(dueDate),
      'completed': completed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Returns a copy of this task with some fields replaced.
  TaskModel copyWith({
    String? title,
    String? description,
    String? subject,
    DateTime? dueDate,
    bool? completed,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }
}
