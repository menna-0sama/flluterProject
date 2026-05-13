import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation/model/track_chat_model.dart';
import 'package:graduation/model/trak-model.dart';
import 'package:graduation/network/dio_client.dart';
import 'package:graduation/network/track_chat_api.dart';
import 'package:graduation/network/trak-API.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Group extends StatefulWidget {
  final int trackId;

  const Group({
    super.key,
    required this.trackId,
  });

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  Timer? _chatTimer;

  bool isLoading = true;
  bool isSending = false;
  bool hasLoadedMessagesOnce = false;

  int? currentUserId;
  String currentUserName = "Me";
  String? currentUserImageUrl;

  static const String savedProfileImageKey = "saved_profile_image_url";

  List<TrackChatModel> messages = [];

  TrackModel? currentTrack;

  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 18;
    if (width < 600) return 24;
    return 30;
  }

  double responsiveFont(BuildContext context, double size) {
    final width = screenWidth(context);
    if (width < 360) return size - 2;
    if (width > 600) return size + 2;
    return size;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDataFromToken();
    loadCurrentUserImage();
    loadTrackData();
    loadMessages();

    _chatTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      loadMessages();
    });
  }

  Future<void> loadCurrentUserImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedImageUrl = prefs.getString(savedProfileImageKey);

      if (!mounted) return;

      setState(() {
        currentUserImageUrl = savedImageUrl;
      });

      print("CHAT CURRENT USER IMAGE: $currentUserImageUrl");
    } catch (e) {
      print("LOAD CHAT USER IMAGE ERROR: $e");
    }
  }

  String getFullImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return "";

    final cleanUrl = url.trim();

    if (cleanUrl.startsWith("http")) {
      return cleanUrl;
    }

    final baseUrl = DioClient.dio.options.baseUrl;
    return Uri.parse(baseUrl).resolve(cleanUrl).toString();
  }

  ImageProvider getChatAvatarImage(String? imageUrl) {
    final fullUrl = getFullImageUrl(imageUrl);

    if (fullUrl.isNotEmpty) {
      return NetworkImage(fullUrl);
    }

    return const AssetImage("images/Ilustration - Home Page.png");
  }

  Future<void> loadTrackData() async {
    final track = await TracksApi.getTrackById(widget.trackId);

    if (!mounted) return;

    setState(() {
      currentTrack = track;
    });
  }

  void getCurrentUserDataFromToken() {
    try {
      final token = DioClient.accessToken;
      if (token == null || token.isEmpty) return;

      final parts = token.split(".");
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );

      final data = jsonDecode(payload);

      final userId = data[
      "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"];

      final email = data[
      "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"];

      currentUserId = int.tryParse(userId.toString());
      currentUserName = email?.toString().split("@").first ?? "Me";

      print("CURRENT USER ID: $currentUserId");
      print("CURRENT USER NAME: $currentUserName");
      print("CURRENT TRACK ID: ${widget.trackId}");
    } catch (e) {
      print("TOKEN DATA ERROR: $e");
    }
  }

  Future<void> loadMessages() async {
    try {
      final result = await TrackChatApi.getMessages(widget.trackId);

      print("GROUP TRACK ID: ${widget.trackId}");
      print("MESSAGES COUNT: ${result.length}");

      if (!mounted) return;

      final bool sameLength = result.length == messages.length;
      final bool sameLastMessage = result.isNotEmpty &&
          messages.isNotEmpty &&
          result.last.id == messages.last.id;

      if (hasLoadedMessagesOnce && sameLength && sameLastMessage) {
        return;
      }

      setState(() {
        messages = result;
        isLoading = false;
        hasLoadedMessagesOnce = true;
      });

      scrollToBottom();
    } catch (e) {
      print("CHAT ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        hasLoadedMessagesOnce = true;
      });
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isSending) return;

    print("SEND TO TRACK ID: ${widget.trackId}");
    print("SEND CONTENT: $text");

    _controller.clear();

    final tempMessage = TrackChatModel(
      id: DateTime.now().millisecondsSinceEpoch,
      content: text,
      sentAt: DateTime.now().toString(),
      senderId: currentUserId ?? 0,
      senderName: currentUserName,
      trackId: widget.trackId,
      senderImageUrl: currentUserImageUrl ?? "",
    );

    setState(() {
      isSending = true;
      messages.add(tempMessage);
    });

    scrollToBottom();

    try {
      await TrackChatApi.sendMessage(
        trackId: widget.trackId,
        content: text,
      );

      await loadMessages();
    } catch (e) {
      print("SEND ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send message")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  Widget messageBubble(TrackChatModel msg) {
    final width = screenWidth(context);
    final bool isUser =
        currentUserId != null && msg.senderId == currentUserId;

    final avatar = CircleAvatar(
      radius: width < 360 ? 14 : 16,
      backgroundColor: Colors.white,
      backgroundImage: getChatAvatarImage(msg.senderImageUrl),
    );

    final bubble = Container(
      padding: EdgeInsets.all(width < 360 ? 10 : 12),
      constraints: BoxConstraints(
        maxWidth: width < 360 ? width * 0.68 : width * 0.62,
      ),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xff2F80ED) : Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            msg.senderName.isEmpty ? "Me" : msg.senderName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: responsiveFont(context, 11),
              color: isUser ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            msg.content,
            style: TextStyle(
              fontSize: responsiveFont(context, 14),
              color: isUser ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );

    return Container(
      margin: EdgeInsets.only(bottom: width < 360 ? 8 : 10),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isUser
            ? [
          Flexible(child: bubble),
          const SizedBox(width: 8),
          avatar,
        ]
            : [
          avatar,
          const SizedBox(width: 8),
          Flexible(child: bubble),
        ],
      ),
    );
  }

  Widget buildTopCard() {
    final width = screenWidth(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 60,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: width < 360 ? 10 : 15,
        vertical: width < 360 ? 10 : 0,
      ),
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
          Flexible(
            flex: 2,
            child: Text(
              currentTrack?.name ?? "Track",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: responsiveFont(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 40, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Image.asset(
                  "images/Logo or icon.png",
                  height: width < 360 ? 30 : 35,
                  width: width < 360 ? 30 : 35,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${currentTrack?.name ?? "Track"}\nKeep up the good work!",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: responsiveFont(context, 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: width < 360 ? 28 : 30,
            height: width < 360 ? 28 : 30,
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
    );
  }

  Widget buildMessageInput() {
    final width = screenWidth(context);

    return Container(
      padding: EdgeInsets.all(width < 360 ? 8 : 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  fontSize: responsiveFont(context, 14),
                ),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(
                    fontSize: responsiveFont(context, 14),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: width < 360 ? 14 : 16,
                    vertical: width < 360 ? 10 : 12,
                  ),
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
                padding: EdgeInsets.all(width < 360 ? 10 : 12),
                decoration: const BoxDecoration(
                  color: Color(0xff2F80ED),
                  shape: BoxShape.circle,
                ),
                child: isSending
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = screenWidth(context);
    final headerHeight = width < 360 ? 360.0 : 452.0;
    final topSpace = width < 360 ? 80.0 : 95.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: headerHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Rectangle 189.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding(context) - 10,
                    right: horizontalPadding(context),
                    top: 12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
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
                ),
                SizedBox(height: topSpace - 52),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding(context),
                  ),
                  child: buildTopCard(),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : messages.isEmpty
                      ? Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: responsiveFont(context, 14),
                      ),
                    ),
                  )
                      : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding(context) - 10,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return messageBubble(messages[index]);
                    },
                  ),
                ),
                buildMessageInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}