import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // ⚠️ Öz IP adresinize üýtgediň (emulator üçin: 10.0.2.2, real device: LAN IP)
  static const String baseUrl = 'http://85.198.97.249:8012';

  static Future<List<QuizSummary>> getQuizzes() async {
    final res = await http.get(Uri.parse('$baseUrl/api/quizzes'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((j) => QuizSummary.fromJson(j)).toList();
    }
    throw Exception('Quizleri ýükläp bolmady');
  }

  static Future<QuizDetail> getQuizDetail(int quizId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/quiz/$quizId'));
    if (res.statusCode == 200) {
      return QuizDetail.fromJson(jsonDecode(res.body));
    }
    throw Exception('Quiz tapylmady');
  }

  static Future<QuizResult> submitQuiz({
    required String playerName,
    required int quizId,
    required Map<String, String> answers,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'player_name': playerName,
        'quiz_id': quizId,
        'answers': answers,
      }),
    );
    if (res.statusCode == 200) {
      return QuizResult.fromJson(jsonDecode(res.body));
    }
    throw Exception('Netije iberilmedi');
  }

  static Future<List<LeaderboardEntry>> getLeaderboard(int quizId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/leaderboard/$quizId'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((j) => LeaderboardEntry.fromJson(j)).toList();
    }
    throw Exception('Liderler tablisasy ýüklenilmedi');
  }
}
