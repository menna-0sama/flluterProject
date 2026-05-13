class AiExamQuestion {
  final dynamic questionId;
  final String question;
  final String difficulty;
  final String topic;
  final String track;

  AiExamQuestion({
    required this.questionId,
    required this.question,
    required this.difficulty,
    required this.topic,
    required this.track,
  });

  factory AiExamQuestion.fromJson(Map<String, dynamic> json) {
    return AiExamQuestion(
      questionId: json["question_id"] ?? json["question_Id"] ?? "",
      question: json["question"]?.toString() ??
          json["question_Text"]?.toString() ??
          "",
      difficulty: json["difficulty"]?.toString() ??
          json["difficulty_Level"]?.toString() ??
          "",
      topic: json["topic"]?.toString() ??
          json["topic_Area"]?.toString() ??
          "",
      track: json["track"]?.toString() ?? "",
    );
  }
}

class AiAnswerResult {
  final String label;
  final double similarity;
  final int points;

  AiAnswerResult({
    required this.label,
    required this.similarity,
    required this.points,
  });

  factory AiAnswerResult.fromJson(Map<String, dynamic> json) {
    return AiAnswerResult(
      label: json["label"]?.toString() ?? "",
      similarity: double.tryParse(json["similarity"].toString()) ?? 0,
      points: int.tryParse(json["points"].toString()) ?? 0,
    );
  }
}

class AiExamFinalResult {
  final int score;
  final String level;
  final List<AiAnswerResult> answers;

  AiExamFinalResult({
    required this.score,
    required this.level,
    required this.answers,
  });

  factory AiExamFinalResult.fromJson(Map<String, dynamic> json) {
    return AiExamFinalResult(
      score: int.tryParse(json["score"].toString()) ?? 0,
      level: json["level"]?.toString() ?? "beginner",
      answers: json["result"] is List
          ? (json["result"] as List)
          .map((e) => AiAnswerResult.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList()
          : [],
    );
  }
}

class AiExamResponse {
  final String sessionId;
  final int questionNumber;
  final int totalQuestions;
  final AiExamQuestion? question;
  final bool isFinished;
  final AiExamFinalResult? finalResult;

  AiExamResponse({
    required this.sessionId,
    required this.questionNumber,
    required this.totalQuestions,
    required this.question,
    required this.isFinished,
    this.finalResult,
  });

  factory AiExamResponse.fromJson(Map<String, dynamic> json) {
    return AiExamResponse(
      sessionId: json["sessionId"]?.toString() ?? "",
      questionNumber: json["questionNumber"] ?? 0,
      totalQuestions: json["totalQuestions"] ?? 10,
      question: json["question"] != null
          ? AiExamQuestion.fromJson(
        Map<String, dynamic>.from(json["question"]),
      )
          : null,
      isFinished: json["isFinished"] ?? false,
      finalResult: json["result"] is Map
          ? AiExamFinalResult.fromJson(
        Map<String, dynamic>.from(json["result"]),
      )
          : null,
    );
  }
}