import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'intro_page.dart';
import 'task_manager.dart';
import 'theme_provider.dart'; // Import the ThemeProvider class

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Your App Title',
            theme: themeProvider.themeData,
            initialRoute: '/',
            routes: {
              '/': (context) => IntroPage(),
              '/main': (context) => TaskManager(),
            },
          );
        },
      ),
    );
  }
}
