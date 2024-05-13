import 'dart:convert';

class Task {
  // Your existing properties and methods...

  // Method to convert tasks map from JSON
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

  // Method to convert tasks map to JSON
  static String tasksToJson(Map<DateTime, List<Task>> tasksByDate) {
    final Map<String, dynamic> tasksMap = {};

    tasksByDate.forEach((date, tasksList) {
      final List<Map<String, dynamic>> tasksJson = tasksList.map((task) => task.toJson()).toList();
      tasksMap[date.toIso8601String()] = tasksJson;
    });

    return jsonEncode(tasksMap);
  }
}
