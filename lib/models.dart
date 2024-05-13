import 'dart:convert';

class Task {
  final String title;
  final String description;
  final DateTime date;
  bool notify;

  Task({
    required this.title,
    required this.description,
    required this.date,
    this.notify = false, // Default value for notify is false
  });

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'notify': notify, // Include notify in JSON
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      notify: json['notify'] ?? false, // Retrieve notify from JSON, default to false if not found
    );
  }

  // Move tasksFromJson method here
  static Map<DateTime, List<Task>> tasksFromJson(String json) {
    final Map<String, dynamic> tasksMap = jsonDecode(json);
    final Map<DateTime, List<Task>> tasksByDate = {};

    tasksMap.forEach((dateString, tasksList) {
      final DateTime date = DateTime.parse(dateString);
      final List<dynamic> tasksData = tasksList as List<dynamic>;
      final List<Task> tasks = tasksData.map((taskJson) => Task.fromJson(taskJson)).toList();
      tasksByDate[date] = tasks;
    });

    return tasksByDate;
  }

  // Move tasksToJson method here
  static String tasksToJson(Map<DateTime, List<Task>> tasksByDate) {
    final Map<String, dynamic> tasksMap = {};

    tasksByDate.forEach((date, tasksList) {
      final List<Map<String, dynamic>> tasksJson = tasksList.map((task) => task.toJson()).toList();
      tasksMap[date.toIso8601String()] = tasksJson;
    });

    return jsonEncode(tasksMap);
  }
}
