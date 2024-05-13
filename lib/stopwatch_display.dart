import 'dart:async';
import 'package:flutter/material.dart';

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
  late TextEditingController _controller;
  late Duration _duration;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _duration = Duration(minutes: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration.inSeconds == 0) {
          _timer.cancel();
          widget.toggleTimer();
        } else {
          _duration -= Duration(seconds: 1);
        }
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Enter duration in minutes',
            ),
            onChanged: (value) {
              setState(() {
                _duration = Duration(minutes: int.tryParse(value) ?? 0);
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(widget.isRunning ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            setState(() {
              if (widget.isRunning) {
                _stopTimer();
              } else {
                _startTimer();
              }
            });
            widget.toggleTimer();
          },
        ),
      ],
    );
  }
}
