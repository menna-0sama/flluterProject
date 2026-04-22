import 'package:flutter/material.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // ✅ FocusNode حقيقي
  final List<Map<String, String>> _messages = [
    {'text': 'Hello! How can I help you today?', 'sender': 'bot'},
    {'text': 'I want to learn Flutter.', 'sender': 'user'},
    {'text': 'Sure! Flutter is amazing for cross-platform apps.', 'sender': 'bot'},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({'text': _controller.text.trim(), 'sender': 'user'});
      _messages.add({'text': 'Bot says: ${_controller.text.trim()}', 'sender': 'bot'});
      _controller.clear();

      // بعد الإرسال نرجع الكيبورد ظاهر
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose(); // ✅ نظف FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0088FF),
        title: Row(
          children: [
            Image.asset(
              "images/Reddit (1).png",
              width: 35,
              height: 35,
            ),
            const SizedBox(width: 10),
            const Text("Chatbot"),
          ],
        ),
      ),
      body: Column(
        children: [
          // الرسائل Scrollable
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xff0088FF) : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isUser ? 12 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 12),
                      ),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // حقل إدخال النص وزر الإرسال
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode, // ✅ FocusNode هنا
                    keyboardType: TextInputType.text, // نوع الكتابة
                    textInputAction: TextInputAction.send, // زر Send
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) => _sendMessage(), // اضغط Enter يرسل
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xff0088FF)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}