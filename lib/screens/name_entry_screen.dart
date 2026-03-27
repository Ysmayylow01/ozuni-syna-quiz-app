import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'quiz_list_screen.dart';

class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _loading = false;
  String? _error;
  late AnimationController _anim;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideIn = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Adyňyzy giriziň!');
      return;
    }
    if (name.length < 2) {
      setState(() => _error = 'Ady has uzyn ýazyň (min 2 harp)');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', name);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => QuizListScreen(playerName: name),
        transitionsBuilder: (_, anim, __, child) =>
            SlideTransition(
              position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background
          Positioned(top: -150, left: -150,
              child: _blob(AppTheme.accent2, 500)),
          Positioned(bottom: -100, right: -100,
              child: _blob(AppTheme.accent, 400)),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),

                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Text(
                          '⚡ QuizApp',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: AppTheme.accent, fontWeight: FontWeight.w700),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'Salam!\nAdyňyz näme?',
                        style: GoogleFonts.dmSans(
                          fontSize: 36, fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary, height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Quiz başlamazdan öň adyňyzy giriziň.\nNetijeler siziň adyňyz bilen ýazylýar.',
                        style: GoogleFonts.dmSans(
                            fontSize: 15, color: AppTheme.textMuted, height: 1.6),
                      ),

                      const SizedBox(height: 52),

                      // Input
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _error != null
                                ? AppTheme.red
                                : _focus.hasFocus
                                    ? AppTheme.accent
                                    : AppTheme.border,
                            width: 1.5,
                          ),
                          boxShadow: _focus.hasFocus
                              ? [BoxShadow(
                                  color: AppTheme.accent.withOpacity(0.1),
                                  blurRadius: 20, spreadRadius: 2)]
                              : [],
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          style: GoogleFonts.dmSans(
                              fontSize: 18, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Mysal: Merdan',
                            hintStyle: GoogleFonts.dmSans(
                                color: AppTheme.textMuted, fontSize: 18),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 16, right: 12),
                              child: Text('👤', style: TextStyle(fontSize: 22)),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) { if (_error != null) setState(() => _error = null); },
                          onSubmitted: (_) => _proceed(),
                        ),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('⚠', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            Text(_error!,
                                style: GoogleFonts.dmSans(
                                    fontSize: 13, color: AppTheme.red)),
                          ],
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Button
                      GestureDetector(
                        onTap: _loading ? null : _proceed,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.accent2, AppTheme.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent2.withOpacity(0.4),
                                blurRadius: 20, offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Center(
                            child: _loading
                                ? const SizedBox(
                                    width: 24, height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Text(
                                    'Başla  →',
                                    style: GoogleFonts.syne(
                                        fontSize: 17, fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Bottom hint
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Text(
                            '📊 Netijeleriňiz liderler tablisasynda görünýär',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: AppTheme.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }
}
