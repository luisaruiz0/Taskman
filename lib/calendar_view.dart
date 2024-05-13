import 'package:flutter/material.dart';
import 'models.dart'; // Import the Task class

class CalendarView extends StatelessWidget {
  final List<Task> tasks;

  const CalendarView({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current date
    DateTime currentDate = DateTime.now();

    // Find tasks for the current date
    List<Task> currentTasks = tasks.where((task) => task.date.year == currentDate.year && task.date.month == currentDate.month && task.date.day == currentDate.day).toList();

    // Show alert dialog if there are tasks for the current date
    if (currentTasks.isNotEmpty) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _showTasksAlert(context, currentTasks);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Center(
              child: Text(
                tasks[index].description,
                style: TextStyle(
                  fontSize: 40.0, // Set the font size to 40
                  fontWeight: FontWeight.bold, // Make the text bold
                ),
              ),
            ),
            subtitle: Text('Date: ${tasks[index].date.toString()}'),
          );
        },
      ),
    );
  }

  void _showTasksAlert(BuildContext context, List<Task> tasks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tasks for Today'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: tasks.map((task) => Text(task.description)).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
