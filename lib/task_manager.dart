import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_editor.dart';
import 'models.dart';
import 'theme_provider.dart';
import 'stopwatch_display.dart';

class CustomTimerDisplay extends StatefulWidget {
  final bool isRunning;
  final Function() toggleTimer;

  const CustomTimerDisplay({
    required this.isRunning,
    required this.toggleTimer,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTimerDisplayState createState() => _CustomTimerDisplayState();
}

class _CustomTimerDisplayState extends State<CustomTimerDisplay> {
  late Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isRunning) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant CustomTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    return IconButton(
      icon: Text('$minutes:${seconds.toString().padLeft(2, '0')}'),
      onPressed: widget.toggleTimer,
    );
  }
}

class TaskManager extends StatefulWidget {
  const TaskManager({Key? key}) : super(key: key);

  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  late Map<DateTime, List<Task>> tasksByDate;
  late SharedPreferences _prefs;
  late DateTime _selectedDateTime;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    tasksByDate = {}; // Initialize tasksByDate here
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _prefs = await SharedPreferences.getInstance();
    final tasksJson = _prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        tasksByDate = Task.tasksFromJson(tasksJson);
      });
    } else {
      tasksByDate = {};
    }
  }

  Future<void> _saveTasks() async {
    await _prefs.setString('tasks', Task.tasksToJson(tasksByDate));
  }

  void _addTask(Task task) {
    setState(() {
      final dateKey = DateTime(task.date.year, task.date.month, task.date.day);
      if (tasksByDate.containsKey(dateKey)) {
        tasksByDate[dateKey]!.add(task);
      } else {
        tasksByDate[dateKey] = [task];
      }
      _saveTasks();
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      final dateKey = DateTime(task.date.year, task.date.month, task.date.day);
      tasksByDate[dateKey]!.remove(task);
      if (tasksByDate[dateKey]!.isEmpty) {
        tasksByDate.remove(dateKey);
      }
      _saveTasks();
    });
  }

  void _markPriority(Task task) {
    setState(() {
      final dateKey = DateTime(task.date.year, task.date.month, task.date.day);
      if (tasksByDate.containsKey(dateKey)) {
        tasksByDate[dateKey]!.remove(task); // Remove the task from its current position
        tasksByDate[dateKey]!.insert(0, task); // Insert the task at the beginning
      } else {
        tasksByDate[dateKey] = [task]; // If the date key doesn't exist, create a new entry with the task
      }
      _saveTasks();
    });
  }

  Future<void> _showAddTaskDialog(BuildContext context, [Task? task]) async {
    final Task? newTask = await showDialog<Task?>(
      context: context,
      builder: (BuildContext context) {
        return TaskEditorDialog(task: task);
      },
    );

    if (newTask != null) {
      _addTask(newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final sortedKeys = tasksByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Task Manager'),
            IconButton(
              icon: Icon(Icons.timer),
              onPressed: () {
                setState(() {
                  _isTimerRunning = !_isTimerRunning;
                });
              },
            ),
            if (_isTimerRunning)
              CustomTimerDisplay(
                isRunning: _isTimerRunning,
                toggleTimer: () {
                  setState(() {
                    _isTimerRunning = !_isTimerRunning;
                  });
                },
              ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final dateKey = sortedKeys[index];
          final tasksForDate = tasksByDate[dateKey]!;

          final isToday = DateTime.now().year == dateKey.year &&
              DateTime.now().month == dateKey.month &&
              DateTime.now().day == dateKey.day;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  isToday ? 'Today' : DateFormat.yMMMd().format(dateKey),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30, // Increased font size
                    fontFamily: 'Comic Sans MS', // Comic Sans MS font
                  ),
                ),
              ),
              Column(
                children: tasksForDate.map((task) {
                  return Dismissible(
                    key: Key(task.title),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _deleteTask(task);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${task.title} deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              _addTask(task);
                            },
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            icon: task.notify ? Icon(Icons.star) : Icon(Icons.star_border),
                            onPressed: () {
                              _markPriority(task); // Mark the task as priority
                            },
                          ),
                        ],
                      ),
                      onTap: () => _showAddTaskDialog(context, task),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
