import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'openai.dart';
import 'package:elevenlabs_flutter/elevenlabs_flutter.dart';
import 'package:http/http.dart' as http;

class RecordChatPage extends StatefulWidget {
  const RecordChatPage({Key? key});

  @override
  State<RecordChatPage> createState() => _RecordChatPageState();
}

class _RecordChatPageState extends State<RecordChatPage> {
  final List<String> _chatMessages = [];
  bool _isStart = false;
  bool _isListening = false;
  late String _micIconText = 'Tap To Speak';
  final SpeechToText _speechToText = SpeechToText();
  late ElevenLabsAPI elevenLabs;
  late AudioPlayer player; // Define AudioPlayer

  // Replace 'YOUR_API_KEY' with your actual API key
  final String apiKey = '4d8d729b8214e267dbc86dc65719a092';

  @override
  void initState() {
    super.initState();
    // Initialize ElevenLabsAPI instance with API key
    elevenLabs = ElevenLabsAPI();
    initSpeech();
    player = AudioPlayer(); //Initialize AudioPlayer
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

  void _start() {
    setState(() {
      _isStart = true;
      _chatMessages.insert(0, 'AI: Hello, Can I help you?');
    });
  }

  void _stop() {
    setState(() {
      _isStart = false;
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

  Future<void> _onSpeechResult(result) async {
    setState(() {
      if (_isListening) {
        _micIconText = 'IsListening';
      } else {
        _micIconText = 'Tap To Speak';
        _chatMessages.insert(0, 'You: ${result.recognizedWords}');
      }
    });

    if (!_isListening) {
      // Send speech-to-text result to OpenAI API
      String response =
          await OpenAI.sendMessageToChatGpt(result.recognizedWords);
      setState(() {
        _chatMessages.insert(0, 'AI: $response');
      });

      /// Play the synthesized text-to-speech response
      await playTextToSpeech(response);
    }
  }

  Future<void> playTextToSpeech(String text) async {
    String voiceRachel =
        '21m00Tcm4TlvDq8ikWAM'; //Rachel voice - change if you know another Voice ID

    String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceRachel';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {"stability": .15, "similarity_boost": .75}
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      await player.setAudioSource(MyCustomSource(bytes));
      player.play();
    } else {
      // Throw Exception or handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white38,
        title: const Text('Talk to GPT'),
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
    if (!_isStart) {
      return ElevatedButton(
        onPressed: _start,
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
            onPressed: _start,
            icon: const Icon(Icons.refresh),
            color: Colors.black,
          ),
          IconButton(
            onPressed:
                _speechToText.isListening ? _stopListening : _startListening,
            icon:
                Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            color: Colors.black,
            tooltip: _micIconText,
          ),
          IconButton(
            onPressed: _stop,
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

// Feed your own stream of bytes into the player
class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
