import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart'; // Import the ThemeProvider class

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late Timer _timer;

  late List<String> words;
  late List<ScrollController> controllers;

  @override
  void initState() {
    super.initState();

    words = [
      'I',
      'am',
      'the',
      'task',
      'man',
      'the',
      'task',
      'man',
      'is',
      'me',
      'where',
      'there',
      'is',
      'tasks',
      'i',
      'am',
      'always',
      'there',
      '!',
    ];

    controllers = List.generate(
      3,
          (index) => ScrollController(),
    );

    // Start moving text automatically
    _timer = Timer.periodic(Duration(milliseconds: 50), (_) {
      for (int i = 0; i < controllers.length; i++) {
        if (controllers[i].hasClients) {
          final newPosition = controllers[i].position.pixels + 1;
          final maxExtent = controllers[i].position.maxScrollExtent;
          if (newPosition >= maxExtent) {
            controllers[i].jumpTo(0);
          } else {
            controllers[i].animateTo(
              newPosition,
              duration: Duration(milliseconds: 50),
              curve: Curves.linear,
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Taskman',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: CircleAvatar(
                    radius: 100, // Adjust the radius as needed
                    backgroundColor: Colors.black.withOpacity(0.5),
                    backgroundImage: AssetImage('assets/palworld2.png'),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 66,
                child: Icon(
                  Icons.cloud,
                  size: 40,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Positioned(
                left: 140,
                bottom: 420, // Adjust the bottom position as needed
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/main');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Set border radius here
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Get Started'),
                  ),
                ),
              ),
              for (var i = 0; i < 3; i++)
                Positioned(
                  left: 20,
                  bottom: 100.0 + (i * 100),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 80, // Adjust the height as needed
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: themeProvider.isDarkMode
                          ? null
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: controllers[i],
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (int j = 0; j < 50; j++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Center(
                              child: Text(
                                words[Random().nextInt(words.length)].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 20, // Adjust the font size as needed
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
