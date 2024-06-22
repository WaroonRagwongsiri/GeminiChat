import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemini_chat/pages/chat_pages.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final apiKey = dotenv.env['APIKEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('API key is missing. Please provide a valid API key in env.json.');
  }

  Gemini.init(apiKey: apiKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gemini Chat',
      theme: ThemeData.dark(),
      home: const ChatPage(),
    );
  }
}