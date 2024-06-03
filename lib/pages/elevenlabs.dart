import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

// String EL_API_KEY = dotenv.env['EL_API_KEY'] as String;

class ElevenLabsIntegration {
  final player = AudioPlayer();

  Future<void> playTextToSpeech(String text) async {
    String voiceRachel = '21m00Tcm4TlvDq8ikWAM';

    String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceRachel';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'audio/mpeg',
        "Authorization": "Bearer ${dotenv.env['EL_API_KEY']}",
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
      return;
    }
  }

  void dispose() {
    player.dispose();
  }
}

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
