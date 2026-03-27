import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'quiz_screen.dart';
import 'name_entry_screen.dart';

class QuizListScreen extends StatefulWidget {
  final String playerName;
  const QuizListScreen({super.key, required this.playerName});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List<QuizSummary> _quizzes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      setState(() { _loading = true; _error = null; });
      final quizzes = await ApiService.getQuizzes();
      setState(() { _quizzes = quizzes; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Server bilen baglanyşyk ýok.\nIP adresini barlaň.'; _loading = false; });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('player_name');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NameEntryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          Positioned(top: -200, right: -100, child: _blob(AppTheme.accent2, 450)),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salam, ${widget.playerName}! 👋',
                              style: GoogleFonts.dmSans(
                                  fontSize: 22, fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quiz saýlaň we başlaň!',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      // User avatar + logout
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [AppTheme.accent2, AppTheme.accent]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              widget.playerName.isNotEmpty
                                  ? widget.playerName[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.syne(
                                  fontSize: 18, fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stats bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        _statItem('📋', '${_quizzes.length}', 'Quiz'),
                        _divider(),
                        _statItem('❓',
                            '${_quizzes.fold(0, (s, q) => s + q.questionCount)}',
                            'Sorag'),
                        _divider(),
                        _statItem('🏆', 'TOP', 'Liderler'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quizler',
                        style: GoogleFonts.dmSans(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary),
                      ),
                      GestureDetector(
                        onTap: _loadQuizzes,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text('↻ Täzele',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: AppTheme.textMuted)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                      : _error != null
                          ? _errorWidget()
                          : _quizzes.isEmpty
                              ? _emptyWidget()
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                  itemCount: _quizzes.length,
                                  itemBuilder: (_, i) => _QuizCard(
                                    quiz: _quizzes[i],
                                    index: i,
                                    playerName: widget.playerName,
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String icon, String val, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(val, style: GoogleFonts.dmSans(
              fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          Text(label, style: GoogleFonts.dmSans(
              fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: AppTheme.border, margin: const EdgeInsets.symmetric(horizontal: 8));
  }

  Widget _errorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(_error!, style: GoogleFonts.dmSans(
                color: AppTheme.textMuted, fontSize: 15), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadQuizzes,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent2, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Täzeden synap gör', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Heniz quiz ýok.\nAdmin panelinden quiz goşuň.',
              style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 15),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }
}

// ────────────────────────────────────────────
//  Quiz Card Widget
// ────────────────────────────────────────────
class _QuizCard extends StatelessWidget {
  final QuizSummary quiz;
  final int index;
  final String playerName;

  const _QuizCard({required this.quiz, required this.index, required this.playerName});

  static const List<List<Color>> _gradients = [
    [Color(0xFF7C3AED), Color(0xFF00E5FF)],
    [Color(0xFF059669), Color(0xFF34D399)],
    [Color(0xFFD97706), Color(0xFFFBBF24)],
    [Color(0xFFDC2626), Color(0xFFF87171)],
  ];

  @override
  Widget build(BuildContext context) {
    final grad = _gradients[index % _gradients.length];
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              QuizScreen(quizId: quiz.id, playerName: playerName),
          transitionsBuilder: (_, anim, __, child) =>
              SlideTransition(
                position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
                child: child,
              ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Color accent left bar
              Positioned(left: 0, top: 0, bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: grad, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: grad),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Text('📝', style: TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(quiz.title,
                              style: GoogleFonts.dmSans(
                                  fontSize: 15, fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          if (quiz.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(quiz.description,
                                style: GoogleFonts.dmSans(
                                    fontSize: 12, color: AppTheme.textMuted),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _tag('❓ ${quiz.questionCount} sorag'),
                              const SizedBox(width: 8),
                              _tag('⏱ ~${quiz.questionCount * 30}s'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: AppTheme.textMuted, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(text, style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted)),
    );
  }
}
