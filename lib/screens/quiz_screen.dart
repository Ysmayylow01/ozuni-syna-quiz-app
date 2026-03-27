import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int quizId;
  final String playerName;
  const QuizScreen({super.key, required this.quizId, required this.playerName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  QuizDetail? _quiz;
  bool _loading = true;
  String? _error;

  int _currentIndex = 0;
  final Map<String, String> _answers = {};
  String? _selectedOption;
  bool _submitting = false;

  late AnimationController _questionAnim;
  late Animation<double> _questionFade;
  late Animation<Offset> _questionSlide;

  @override
  void initState() {
    super.initState();
    _questionAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _questionFade = CurvedAnimation(parent: _questionAnim, curve: Curves.easeOut);
    _questionSlide = Tween(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _questionAnim, curve: Curves.easeOut));
    _loadQuiz();
  }

  @override
  void dispose() { _questionAnim.dispose(); super.dispose(); }

  Future<void> _loadQuiz() async {
    try {
      final quiz = await ApiService.getQuizDetail(widget.quizId);
      setState(() { _quiz = quiz; _loading = false; });
      _questionAnim.forward();
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _selectOption(String option) {
    if (_selectedOption != null) return; // already answered
    setState(() => _selectedOption = option);

    // Auto advance after 1 second
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final q = _quiz!.questions[_currentIndex];
      _answers[q.id.toString()] = option;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    final isLast = _currentIndex == _quiz!.questions.length - 1;
    if (isLast) {
      _submitQuiz();
      return;
    }
    _questionAnim.reverse().then((_) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
      _questionAnim.forward();
    });
  }

  Future<void> _submitQuiz() async {
    setState(() => _submitting = true);
    try {
      final result = await ApiService.submitQuiz(
        playerName: widget.playerName,
        quizId: widget.quizId,
        answers: _answers,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ResultScreen(
            result: result,
            quizId: widget.quizId,
            playerName: widget.playerName,
            quizTitle: _quiz!.title,
          ),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Netije iberilmedi: $e'), backgroundColor: AppTheme.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }
    if (_error != null || _quiz == null) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(child: Text(_error ?? 'Ýalňyşlyk',
            style: GoogleFonts.dmSans(color: AppTheme.red))),
      );
    }

    final q = _quiz!.questions[_currentIndex];
    final progress = (_currentIndex + 1) / _quiz!.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showQuitDialog(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_currentIndex + 1} / ${_quiz!.questions.length}',
                              style: GoogleFonts.syne(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: AppTheme.textMuted),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: GoogleFonts.syne(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: AppTheme.accent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppTheme.border,
                            valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quiz title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _quiz!.title,
                style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted),
                textAlign: TextAlign.center,
              ),
            ),

            Expanded(
              child: FadeTransition(
                opacity: _questionFade,
                child: SlideTransition(
                  position: _questionSlide,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question number badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Sorag ${_currentIndex + 1}',
                            style: GoogleFonts.syne(
                                fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Question text
                        Text(
                          q.questionText,
                          style: GoogleFonts.syne(
                              fontSize: 20, fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary, height: 1.4),
                        ),

                        const SizedBox(height: 32),

                        // Options
                        ...q.options.map((entry) => _OptionTile(
                          label: entry.key,
                          text: entry.value,
                          selected: _selectedOption == entry.key,
                          onTap: () => _selectOption(entry.key),
                        )),

                        const Spacer(),

                        // Skip / Next button
                        if (_selectedOption == null)
                          GestureDetector(
                            onTap: () {
                              // skip without answering
                              final q2 = _quiz!.questions[_currentIndex];
                              _answers[q2.id.toString()] = 'X';
                              _nextQuestion();
                            },
                            child: Center(
                              child: Text(
                                'Bu soragy geç →',
                                style: GoogleFonts.dmSans(
                                    fontSize: 14, color: AppTheme.textMuted,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (_submitting)
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text('Netije iberilýär...',
                        style: GoogleFonts.dmSans(color: AppTheme.textMuted)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Quizi terk etmek', style: GoogleFonts.syne(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Quizi tamamlamadyňyz. Çykmak isleýärsiňizmi?',
            style: GoogleFonts.dmSans(color: AppTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Ýok', style: GoogleFonts.syne(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Çyk', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────
//  Option Tile
// ────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withOpacity(0.1) : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppTheme.accent.withOpacity(0.1), blurRadius: 12, spreadRadius: 2)]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.accent
                    : AppTheme.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? AppTheme.accent : AppTheme.border,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.syne(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: selected ? AppTheme.bg : AppTheme.textMuted),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: selected ? AppTheme.textPrimary : AppTheme.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
