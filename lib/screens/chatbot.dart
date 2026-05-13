import 'package:flutter/material.dart';
import 'package:graduation/screens/courses.dart';
import 'package:graduation/model/ai_exam_model.dart';
import 'package:graduation/network/ai_exam_api.dart';
import 'package:graduation/network/trak-API.dart';

class Chatbot extends StatefulWidget {
  final int trackId;

  const Chatbot({
    super.key,
    required this.trackId,
  });

  @override
  State<Chatbot> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<Chatbot> {
  final TextEditingController _answerController = TextEditingController();

  AiExamResponse? examData;

  bool isLoading = true;
  bool isAnswering = false;
  bool showResult = false;

  String errorMessage = "";
  String resultLevel = "beginner";

  int resultScore = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;

  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

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

  @override
  void initState() {
    super.initState();
    startExam();
  }

  String normalizeTrackName(String name) {
    return name.toLowerCase().replaceAll("-", "").replaceAll(" ", "").trim();
  }

  Future<void> startExam() async {
    try {
      setState(() {
        isLoading = true;
        showResult = false;
        errorMessage = "";
        resultScore = 0;
        correctAnswers = 0;
        wrongAnswers = 0;
        resultLevel = "beginner";
      });

      final track = await TracksApi.getTrackById(widget.trackId);
      final trackName = normalizeTrackName(track?.name ?? "frontend");

      final result = await AiExamApi.startExam(trackName);

      if (!mounted) return;

      setState(() {
        examData = result;
        isLoading = false;
      });
    } catch (e) {
      print("START EXAM ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Failed to start exam";
      });
    }
  }

  Future<void> nextQuestion() async {
    final answer = _answerController.text.trim();

    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write your answer")),
      );
      return;
    }

    if (examData == null || isAnswering) return;

    try {
      setState(() {
        isAnswering = true;
      });

      final result = await AiExamApi.sendAnswer(
        sessionId: examData!.sessionId,
        studentAnswer: answer,
      );

      _answerController.clear();

      if (!mounted) return;

      setState(() {
        examData = result;
        isAnswering = false;

        if (result.isFinished) {
          resultScore = result.finalResult?.score ?? 0;
          resultLevel = result.finalResult?.level.toLowerCase() ?? "beginner";

          correctAnswers = result.finalResult?.answers
              .where((e) => e.label.toLowerCase() == "correct")
              .length ??
              0;

          wrongAnswers = result.finalResult?.answers
              .where((e) => e.label.toLowerCase() == "wrong")
              .length ??
              0;

          showResult = true;
        }
      });
    } catch (e) {
      print("ANSWER ERROR: $e");

      if (!mounted) return;

      setState(() {
        isAnswering = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send answer")),
      );
    }
  }

  void startAgain() {
    _answerController.clear();
    startExam();
  }

  double get progressValue {
    if (examData == null || examData!.totalQuestions == 0) return 0;
    return examData!.questionNumber / examData!.totalQuestions;
  }

  int get progressPercent => (progressValue * 100).toInt();

  bool get isLastQuestion {
    if (examData == null) return false;
    return examData!.questionNumber == examData!.totalQuestions;
  }

  String get level => resultLevel.toLowerCase();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Widget buildTopBar() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: const Icon(Icons.arrow_back, color: Colors.black),
    );
  }

  Widget buildQuestionInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "Question ${examData?.questionNumber ?? 0} / ${examData?.totalQuestions ?? 0}",
            style: TextStyle(
              fontSize: responsiveFont(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          "$progressPercent%",
          style: TextStyle(
            fontSize: responsiveFont(context, 16),
            color: const Color(0xff2F80ED),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progressValue,
        minHeight: 8,
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation(
          Color(0xff2F80ED),
        ),
      ),
    );
  }

  Widget buildQuestionCard() {
    final question = examData?.question;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Topic: ${question?.topic ?? ""}",
          style: TextStyle(
            fontSize: responsiveFont(context, 17),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 120,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            question?.question ?? "",
            style: TextStyle(
              fontSize: responsiveFont(context, 18),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAnswerBox() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: screenHeight(context) * 0.18,
        maxHeight: screenHeight(context) * 0.28,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _answerController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: "Type your answer here...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildNextButton() {
    return GestureDetector(
      onTap: isAnswering ? null : nextQuestion,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: screenWidth(context) < 360 ? 130 : 150,
          height: 52,
          decoration: BoxDecoration(
            color: isLastQuestion
                ? const Color(0xff27AE60)
                : const Color(0xff2F80ED),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isAnswering
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              isLastQuestion ? "Submit ✓" : "Next →",
              style: TextStyle(
                color: Colors.white,
                fontSize: responsiveFont(context, 17),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuestionScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding(context),
                vertical: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTopBar(),
                  const SizedBox(height: 30),
                  buildQuestionInfo(),
                  const SizedBox(height: 15),
                  buildProgressBar(),
                  const SizedBox(height: 30),
                  buildQuestionCard(),
                  const SizedBox(height: 20),
                  buildAnswerBox(),
                  const SizedBox(height: 30),
                  buildNextButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildResultScreen() {
    final total = examData?.totalQuestions ?? 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding(context),
                vertical: 30,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: buildTopBar(),
                  ),
                  SizedBox(height: screenHeight(context) * 0.06),
                  Container(
                    width: screenWidth(context) < 360 ? 100 : 120,
                    height: screenWidth(context) < 360 ? 100 : 120,
                    decoration: BoxDecoration(
                      color: const Color(0xffDFF8E8),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: const Color(0xff27AE60),
                      size: screenWidth(context) < 360 ? 60 : 70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Your Result",
                    style: TextStyle(
                      fontSize: responsiveFont(context, 26),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth(context) < 360 ? 110 : 130,
                        height: screenWidth(context) < 360 ? 110 : 130,
                        child: CircularProgressIndicator(
                          value: resultScore / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xff2F80ED),
                          ),
                        ),
                      ),
                      Text(
                        "$resultScore%",
                        style: TextStyle(
                          fontSize: responsiveFont(context, 28),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Level: $level",
                    style: TextStyle(
                      fontSize: responsiveFont(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(child: Text("Correct Answers")),
                            Text(
                              "$correctAnswers / $total",
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(child: Text("Wrong Answers")),
                            Text(
                              "$wrongAnswers / $total",
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight(context) * 0.08),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Courses(
                            trackId: widget.trackId,
                            level: level,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xff2F80ED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsiveFont(context, 17),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: startAgain,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xff2F80ED)),
                      ),
                      child: Center(
                        child: Text(
                          "Start Again",
                          style: TextStyle(
                            color: const Color(0xff2F80ED),
                            fontSize: responsiveFont(context, 17),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildErrorScreen() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(horizontalPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsiveFont(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: startExam,
              child: Container(
                width: screenWidth(context) < 360 ? 130 : 150,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xff2F80ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Try Again",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveFont(context, 17),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (isLoading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      child = buildErrorScreen();
    } else if (showResult) {
      child = buildResultScreen();
    } else {
      child = buildQuestionScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: child),
    );
  }
}