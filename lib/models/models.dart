class QuizSummary {
  final int id;
  final String title;
  final String description;
  final int questionCount;

  QuizSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.questionCount,
  });

  factory QuizSummary.fromJson(Map<String, dynamic> j) => QuizSummary(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        questionCount: j['question_count'] ?? 0,
      );
}

class QuizDetail {
  final int id;
  final String title;
  final String description;
  final List<Question> questions;

  QuizDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  factory QuizDetail.fromJson(Map<String, dynamic> j) => QuizDetail(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        questions: (j['questions'] as List)
            .map((q) => Question.fromJson(q))
            .toList(),
      );
}

class Question {
  final int id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;

  Question({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: j['id'],
        questionText: j['question_text'] ?? '',
        optionA: j['option_a'] ?? '',
        optionB: j['option_b'] ?? '',
        optionC: j['option_c'] ?? '',
        optionD: j['option_d'] ?? '',
      );

  List<MapEntry<String, String>> get options => [
        MapEntry('A', optionA),
        MapEntry('B', optionB),
        MapEntry('C', optionC),
        MapEntry('D', optionD),
      ];
}

class QuizResult {
  final int score;
  final int total;
  final double percentage;
  final String message;

  QuizResult({
    required this.score,
    required this.total,
    required this.percentage,
    required this.message,
  });

  factory QuizResult.fromJson(Map<String, dynamic> j) => QuizResult(
        score: j['score'],
        total: j['total'],
        percentage: (j['percentage'] as num).toDouble(),
        message: j['message'] ?? '',
      );
}

class LeaderboardEntry {
  final int rank;
  final String playerName;
  final int score;
  final int total;
  final double percentage;

  LeaderboardEntry({
    required this.rank,
    required this.playerName,
    required this.score,
    required this.total,
    required this.percentage,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) => LeaderboardEntry(
        rank: j['rank'],
        playerName: j['player_name'],
        score: j['score'],
        total: j['total'],
        percentage: (j['percentage'] as num).toDouble(),
      );
}
