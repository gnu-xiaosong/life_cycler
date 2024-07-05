import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'Todo.dart';

class Task {
  String? taskId = "task_" + Uuid().v4().toString();
  String? userId;
  String? name;
  String? label;
  String? category;
  String? description;
  String priority = 'Low';
  String status = 'pending';
  DateTime? startTime;
  DateTime? endTime;
  List<Todo>? todos = [];

  @override
  String toString() {
    return '''
      Task {
        taskId: $taskId,
        userId: $userId,
        name: $name,
        label: $label,
        category: $category,
        description: $description,
        priority: $priority,
        status: $status,
        startTime: $startTime,
        endTime: $endTime,
        todos: ${todos?.map((e) => e.toMap()).toList()}
      }
    ''';
  }
}
