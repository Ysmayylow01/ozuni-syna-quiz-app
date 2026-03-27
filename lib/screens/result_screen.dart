import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'quiz_list_screen.dart';

class ResultScreen extends StatefulWidget {
  final QuizResult result;
  final int quizId;
  final String playerName;
  final String quizTitle;

  const ResultScreen({
    super.key,
    required this.result,
    required this.quizId,
    required this.playerName,
    required this.quizTitle,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;
  late Animation<double> _fade;
  List<LeaderboardEntry> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.5, end: 1).animate(
        CurvedAnimation(parent: _anim, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _anim, curve: const Interval(0.4, 1, curve: Curves.easeOut));
    _anim.forward();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final lb = await ApiService.getLeaderboard(widget.quizId);
      if (mounted) setState(() => _leaderboard = lb);
    } catch (_) {}
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  Color get _scoreColor {
    if (widget.result.percentage >= 80) return AppTheme.green;
    if (widget.result.percentage >= 50) return AppTheme.yellow;
    return AppTheme.red;
  }

  String get _emoji {
    if (widget.result.percentage >= 80) return '🏆';
    if (widget.result.percentage >= 50) return '👍';
    return '💪';
  }

  String get _message {
    if (widget.result.percentage >= 80) return 'Ajaýyp netije!';
    if (widget.result.percentage >= 50) return 'Gowy synanyşyk!';
    return 'Dowam et, başararsyň!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background glow
          Positioned(top: -100, left: 0, right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [_scoreColor.withOpacity(0.15), Colors.transparent],
                  radius: 0.8,
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Score circle
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surface,
                        border: Border.all(color: _scoreColor.withOpacity(0.5), width: 3),
                        boxShadow: [BoxShadow(
                            color: _scoreColor.withOpacity(0.3),
                            blurRadius: 40, spreadRadius: 5)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_emoji, style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.result.percentage.round()}%',
                            style: GoogleFonts.syne(
                                fontSize: 28, fontWeight: FontWeight.w800,
                                color: _scoreColor),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        Text(_message,
                            style: GoogleFonts.syne(
                                fontSize: 26, fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.playerName}, sen ${widget.result.score} / ${widget.result.total} dogry jogap berdiň!',
                          style: GoogleFonts.dmSans(
                              fontSize: 15, color: AppTheme.textMuted, height: 1.5),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Stats cards
                        Row(
                          children: [
                            _statCard('✅', '${widget.result.score}', 'Dogry', AppTheme.green),
                            const SizedBox(width: 12),
                            _statCard('❌', '${widget.result.total - widget.result.score}', 'Ýalňyş', AppTheme.red),
                            const SizedBox(width: 12),
                            _statCard('📊', '${widget.result.percentage.round()}%', 'Görkeziji', _scoreColor),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Leaderboard
                        if (_leaderboard.isNotEmpty) ...[
                          Row(
                            children: [
                              const Text('🏆', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text('Liderler Tablisasy',
                                  style: GoogleFonts.syne(
                                      fontSize: 18, fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Column(
                              children: _leaderboard.asMap().entries.map((e) =>
                                  _LeaderRow(entry: e.value, isLast: e.key == _leaderboard.length - 1,
                                      highlightName: widget.playerName)
                              ).toList(),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Buttons
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) =>
                                QuizListScreen(playerName: widget.playerName)),
                            (_) => false,
                          ),
                          child: Container(
                            width: double.infinity, height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [AppTheme.accent2, AppTheme.accent]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(
                                  color: AppTheme.accent2.withOpacity(0.4),
                                  blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: Center(
                              child: Text('← Quiz sanawyna qayyt',
                                  style: GoogleFonts.syne(
                                      fontSize: 16, fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String icon, String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(val, style: GoogleFonts.syne(
                fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: GoogleFonts.dmSans(
                fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isLast;
  final String highlightName;

  const _LeaderRow({required this.entry, required this.isLast, required this.highlightName});

  @override
  Widget build(BuildContext context) {
    final isMe = entry.playerName == highlightName;
    final rankColors = {1: const Color(0xFFF59E0B), 2: const Color(0xFF94A3B8), 3: const Color(0xFFB45309)};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accent.withOpacity(0.05) : null,
        border: !isLast ? const Border(bottom: BorderSide(color: AppTheme.border)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              entry.rank <= 3 ? ['🥇','🥈','🥉'][entry.rank-1] : '${entry.rank}',
              style: entry.rank <= 3
                  ? const TextStyle(fontSize: 18)
                  : GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700,
                  color: rankColors[entry.rank] ?? AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(entry.playerName,
                style: GoogleFonts.syne(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: isMe ? AppTheme.accent : AppTheme.textPrimary)),
          ),
          Text('${entry.score}/${entry.total}',
              style: GoogleFonts.syne(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: entry.percentage >= 70
                      ? AppTheme.green
                      : entry.percentage >= 40
                          ? AppTheme.yellow
                          : AppTheme.red)),
          const SizedBox(width: 8),
          Text('${entry.percentage.round()}%',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}
