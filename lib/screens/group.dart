import 'package:flutter/material.dart';

class Group extends StatefulWidget {
  const Group({super.key});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ScrollController _scrollController = ScrollController(); // 👈 إضافة جديدة

  List<Map<String, dynamic>> messages = [
    {
      "text": "Hey there! Ready to start your journey today?",
      "isUser": false,
    },
    {
      "text": "Yes, I want some help",
      "isUser": true,
    },
    {
      "text": "Great! Let's begin 🚀",
      "isUser": false,
    },
  ];

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "text": _controller.text,
        "isUser": true,
      });
    });

    _controller.clear();
    scrollToBottom(); // 👈 مهم
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom(); // أول فتح الصفحة
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ===== Background =====
          Container(
            width: double.infinity,
            height: 452,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Rectangle 189.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ===== Back Button =====
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),

          // ===== Chat UI =====
          Column(
            children: [
              const SizedBox(height: 120),

              // ===== Top Card =====
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "72 Active",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "250 member",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 40, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Image.asset(
                              "images/Logo or icon.png",
                              height: 35,
                              width: 35,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Flutter\nKeep up the good work!",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xff0088FF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ===== Messages =====
              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // 👈 إضافة مهمة
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];

                    return Align(
                      alignment: msg["isUser"]
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),

                        child: Row(
                          mainAxisAlignment: msg["isUser"]
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            // bot avatar
                            if (!msg["isUser"])
                              const CircleAvatar(
                                radius: 16,
                                backgroundImage: AssetImage(
                                    "images/Ilustration - Home Page.png"),
                              ),

                            if (!msg["isUser"])
                              const SizedBox(width: 8),

                            // message
                            Container(
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context).size.width * 0.65,
                              ),
                              decoration: BoxDecoration(
                                color: msg["isUser"]
                                    ? const Color(0xff2F80ED)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                msg["text"],
                                style: TextStyle(
                                  color: msg["isUser"]
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),

                            // user avatar
                            if (msg["isUser"])
                              const SizedBox(width: 8),

                            if (msg["isUser"])
                              const CircleAvatar(
                                radius: 16,
                                backgroundImage:
                                AssetImage("images/user.png"),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ===== Input field =====
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xff2F80ED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}