import 'dart:io';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

class ChatResult {
  final String id;
  final AIChatMessage output;
  final String finishReason;
  final Map<String, dynamic> metadata;
  final LanguageModelUsage usage;
  final bool streaming;

  ChatResult(
      {required this.id,
      required this.output,
      required this.finishReason,
      required this.metadata,
      required this.usage,
      required this.streaming});
}

class OpenAI {
  static Future<String> sendMessageToChatGpt(String message) async {
    final openaiApiKey = Platform.environment['OPENAI_API_KEY'];

    final promptTemplate = ChatPromptTemplate.fromTemplates(const [
      (
        ChatMessageType.system,
        'You are an English teacher. Your role is to engage in a conversation with your student in a friendly and enjoyable manner. If there are any mistakes in their English, gently correct them within the conversation by pointing out the mistake and providing the correct usage.  If the student uses another language, gently remind them to ask their questions in English. Provide an explanation in Indonesian at the end of your response with the format "Notes:" (Explanation must be in Indonesian) whenever you make a correction. If there are no mistakes or corrections, continue the conversation normally without including "Notes:" at the end.'
      ),
      (
        ChatMessageType.human,
        '### Current Student Inquiry:\n{input}\n\n### Response:'
      )
    ]);

    final chatModel = ChatOpenAI(
        apiKey: openaiApiKey,
        defaultOptions: const ChatOpenAIOptions(
            maxTokens: 500, temperature: 0.2, model: "gpt-4o"));

    final chain = promptTemplate | chatModel | const StringOutputParser();

    final res = await chain.invoke({
      'input': message,
    });

    if (res is ChatResult) {
      String chatContent = res.output.content;
      return chatContent;
    } else {
      return "";
    }
  }
}
