import 'package:flutter/material.dart';
import 'package:graduation/network/progress_api.dart';
import 'package:url_launcher/url_launcher.dart';

class Studypage extends StatefulWidget {
  final int lessonId;
  final String title;
  final String description;
  final List<String> videos;
  final String? articleUrl;

  const Studypage({
    super.key,
    required this.lessonId,
    required this.title,
    required this.description,
    this.videos = const [],
    this.articleUrl,
  });

  @override
  State<Studypage> createState() => _StudypageState();
}

class _StudypageState extends State<Studypage> {
  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 18;
    if (width < 600) return 24;
    return 34;
  }

  double responsiveFont(BuildContext context, double size) {
    final width = screenWidth(context);
    if (width < 360) return size - 2;
    if (width > 600) return size + 2;
    return size;
  }

  Future<void> openLink(BuildContext context, String? url) async {
    if (url == null || url.trim().isEmpty || url == "null") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Link not available")),
      );
      return;
    }

    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  Future<void> completeLesson(BuildContext context) async {
    try {
      if (widget.lessonId != 0) {
        await ProgressApi.completeLesson(lessonId: widget.lessonId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lesson completed")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error completing lesson")),
      );
    }
  }

  Widget buildHeaderImage() {
    final width = screenWidth(context);

    final videoHeight = width < 360
        ? 135.0
        : width < 600
        ? 165.0
        : 210.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "images/Rectangle 257 (2).png",
            width: double.infinity,
            height: videoHeight,
            fit: BoxFit.cover,
          ),
          Container(
            width: width < 360 ? 54 : 62,
            height: width < 360 ? 54 : 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              size: width < 360 ? 34 : 40,
              color: const Color(0xff2678C5),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVideoCard(int index, String url) {
    final width = screenWidth(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => openLink(context, url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(width < 360 ? 10 : 12),
        decoration: BoxDecoration(
          color: const Color(0xffF3F8FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffD7EAFF)),
        ),
        child: Row(
          children: [
            Container(
              width: width < 360 ? 46 : 52,
              height: width < 360 ? 46 : 52,
              decoration: BoxDecoration(
                color: const Color(0xff2678C5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: width < 360 ? 26 : 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Video ${index + 1}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: responsiveFont(context, 15),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new,
              color: const Color(0xff2678C5),
              size: width < 360 ? 18 : 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildArticleCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => openLink(context, widget.articleUrl),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth(context) < 360 ? 12 : 14),
        decoration: BoxDecoration(
          color: const Color(0xffFFF8EC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffFFE0AA)),
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth(context) < 360 ? 46 : 52,
              height: screenWidth(context) < 360 ? 46 : 52,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.article,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Read Article",
                style: TextStyle(
                  fontSize: responsiveFont(context, 15),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.open_in_new,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVideosSection() {
    if (widget.videos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("No videos available"),
      );
    }

    return Column(
      children: List.generate(
        widget.videos.length,
            (index) => buildVideoCard(index, widget.videos[index]),
      ),
    );
  }

  Widget buildNextButton() {
    return GestureDetector(
      onTap: () => completeLesson(context),
      child: Container(
        width: double.infinity,
        height: screenWidth(context) < 360 ? 48 : 54,
        decoration: BoxDecoration(
          color: const Color(0xff2678C5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "Next Lesson",
              style: TextStyle(
                color: Colors.white,
                fontSize: responsiveFont(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = screenWidth(context);
    final headerHeight = width < 360 ? 330.0 : 380.0;

    return Scaffold(
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding(context),
                  vertical: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(25),
                      child: const SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(width < 360 ? 12 : 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildHeaderImage(),
                          const SizedBox(height: 16),
                          Text(
                            widget.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: responsiveFont(context, 21),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: responsiveFont(context, 13),
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Videos",
                            style: TextStyle(
                              fontSize: responsiveFont(context, 17),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          buildVideosSection(),
                          const SizedBox(height: 6),
                          buildArticleCard(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    buildNextButton(),
                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}