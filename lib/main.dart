// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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

class RecordChatPage extends StatefulWidget {
  const RecordChatPage({Key? key});

  @override
  _RecordChatPageState createState() => _RecordChatPageState();
}

class _RecordChatPageState extends State<RecordChatPage> {
  final List<String> _chatMessages = [];
  bool _isRecording = false;

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _chatMessages.insert(0, 'AI: Hello, Can I help you?');
    });
  }

  void _micPressed() {
    setState(() {
      _chatMessages.insert(0, 'You: Text from recorded audio');
      _chatMessages.insert(0, 'AI: Response');
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _chatMessages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white38,
        title: const Text('Conversation App'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                return _buildChatBubble(_chatMessages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    if (!_isRecording) {
      return ElevatedButton(
        onPressed: _startRecording,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Start',
          style: TextStyle(fontSize: 22, color: Colors.black),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _startRecording,
            icon: const Icon(Icons.refresh),
            color: Colors.black,
          ),
          IconButton(
            onPressed: _micPressed,
            icon: const Icon(Icons.mic),
            color: Colors.black,
          ),
          IconButton(
            onPressed: _stopRecording,
            icon: const Icon(Icons.stop),
            color: Colors.black,
          ),
        ],
      );
    }
  }

  Widget _buildChatBubble(String text) {
    final isResponse = text.startsWith('AI:');

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isResponse ? Colors.black26 : Colors.white54,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isResponse
                ? const Radius.circular(0)
                : const Radius.circular(16),
            bottomRight: isResponse
                ? const Radius.circular(16)
                : const Radius.circular(0),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.lato(
            textStyle: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ));
  }
}
