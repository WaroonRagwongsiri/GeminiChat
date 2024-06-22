import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemini_chat/widgets/chat_input_box.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  bool _loading = false;
  final List<Content> chats = [];

  bool get loading => _loading;

  set loading(bool value) {
    setState(() {
      _loading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gemini Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: chats.isNotEmpty
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      reverse: true,
                      child: ListView.builder(
                        itemBuilder: chatItem,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: chats.length,
                        reverse: false,
                      ),
                    ),
                  )
                : const Center(child: Text('Type a message to start chat!')),
          ),
          if (loading) const CircularProgressIndicator(),
          ChatInputBox(
            controller: controller,
            onSend: () async {
              if (controller.text.isNotEmpty) {
                final userMessage = controller.text;
                setState(() {
                  chats.add(
                      Content(role: 'user', parts: [Parts(text: userMessage)]));
                  controller.clear();
                  loading = true;
                });

                try {
                  final response = await gemini.chat(chats);
                  setState(() {
                    chats.add(Content(
                        role: 'model', parts: [Parts(text: response?.output)]));
                  });
                } catch (error) {
                  setState(() {
                    chats.add(Content(
                        role: 'model',
                        parts: [Parts(text: 'Error: ${error.toString()}')]));
                  });
                } finally {
                  loading = false;
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget chatItem(BuildContext context, int index) {
    final Content content = chats[index];

    return Card(
      elevation: 0,
      color:
          content.role == 'model' ? Colors.blue.shade800 : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.role ?? 'role'),
            Markdown(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              data: content.parts?.lastOrNull?.text ?? 'No response',
            ),
          ],
        ),
      ),
    );
  }
}
