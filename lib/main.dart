import 'package:conv_app/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Record & Chat App',
      theme: ThemeData(
        //primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey,
      ),
      home: const RecordChatPage(),
    );
  }
}
