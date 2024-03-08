import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
//import 'package:text_to_speech/text_to_speech.dart';

class RecordChatPage extends StatefulWidget {
  const RecordChatPage({super.key});

  @override
  State<RecordChatPage> createState() => _RecordChatPageState();
}

class _RecordChatPageState extends State<RecordChatPage> {
  final List<String> _chatMessages = [];
  bool _isRecording = false;
  bool _isListening = false;
  late String _micIconText = 'Tap To Speak';
  final SpeechToText _speechToText = SpeechToText();

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechToText.initialize(onStatus: (status) {
      if (kDebugMode) {
        print('Speech status: $status');
      }
    }, onError: (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    });
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _chatMessages.insert(0, 'AI: Hello, Can I help you?');
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _chatMessages.clear();
    });
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(result) {
    setState(() {
      if (_isListening) {
        _micIconText = 'IsListening';
      } else {
        _micIconText = 'Tap To Speak';
        _chatMessages.insert(0, 'You: ${result.recognizedWords}');
      }
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
        leading: const Icon(Icons.menu),
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
            //onPressed: _micPressed,
            onPressed:
                _speechToText.isListening ? _stopListening : _startListening,
            icon:
                Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            color: Colors.black,
            tooltip: _micIconText,
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
