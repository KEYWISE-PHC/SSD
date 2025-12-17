import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colours.dart';

class StrengthFeedbackScreen extends StatefulWidget {
  const StrengthFeedbackScreen({super.key});

  @override
  State<StrengthFeedbackScreen> createState() =>
      _StrengthFeedbackScreenState();
}

class _StrengthFeedbackScreenState extends State<StrengthFeedbackScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _obscure = true;
  double _entropyBits = 0.0;
  int _score = 0; // 0–100 for the gauge
  String _strengthLabel = 'Very Weak';
  Color _strengthColor = Colors.red;
  List<String> _suggestions = const [
    'Type a password to see feedback.',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _onPasswordChanged(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /* ───────────── Password analysis ───────────── */

  void _onPasswordChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _entropyBits = 0;
        _score = 0;
        _strengthLabel = 'Very Weak';
        _strengthColor = Colors.red;
        _suggestions = const ['Type a password to see feedback.'];
      });
      return;
    }

    final length = value.length;
    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(value);

    int pool = 0;
    if (hasLower) pool += 26;
    if (hasUpper) pool += 26;
    if (hasDigit) pool += 10;
    if (hasSymbol) pool += 33;

    double bits = 0;
    if (pool > 0) {
      bits = length * (log(pool) / log(2));
    }

    String label;
    Color color;

    if (bits < 28) {
      label = 'Very Weak';
      color = Colors.red;
    } else if (bits < 36) {
      label = 'Weak';
      color = Colors.orange;
    } else if (bits < 60) {
      label = 'Fair';
      color = const Color.fromARGB(255, 229, 255, 0);
    } else if (bits < 90) {
      label = 'Strong';
      color = const Color.fromARGB(255, 95, 209, 99);
    } else {
      label = 'Very Strong';
      color = const Color.fromARGB(255, 0, 158, 82);
    }

    final List<String> suggestions = [];
    if (bits >= 80) {
      suggestions.add('Nice! This looks like a strong password.');
    } else {
      if (!hasUpper) suggestions.add('Add uppercase letters.');
      if (!hasLower) suggestions.add('Add lowercase letters.');
      if (!hasDigit) suggestions.add('Add numbers.');
      if (!hasSymbol) suggestions.add('Add special characters.');
      if (length < 12) {
        suggestions.add('Consider making it longer (12+ characters).');
      }
    }

    setState(() {
      _entropyBits = bits;
      _score = bits.clamp(0, 100).toInt();
      _strengthLabel = label;
      _strengthColor = color;
      _suggestions = suggestions;
    });
  }

  Future<void> _copyPassword() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password copied to clipboard')),
    );
  }

  /* ───────────── UI ───────────── */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Strength'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.navy,
              AppColors.darkTeal,
              AppColors.midTeal,
              AppColors.brightTeal,
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPasswordField(),
                      const SizedBox(height: 18),
                      _buildScoreRow(),
                      const SizedBox(height: 12),
                      _buildSuggestions(),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _StrengthMeterPainter(
                            value: _score / 100.0,
                            color: _strengthColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _controller,
      cursorColor: AppColors.brightTeal,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: 'Enter password',
        labelStyle: const TextStyle(
          color: AppColors.brightTeal, // requested colour
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.brightTeal,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.brightTeal.withValues(alpha: 0.6),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.brightTeal,
            width: 2,
          ),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Copy password',
              icon: const Icon(Icons.copy),
              color: AppColors.brightTeal,
              onPressed: _copyPassword,
            ),
            IconButton(
              tooltip: _obscure ? 'Show password' : 'Hide password',
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
              ),
              // eye becomes brightTeal when active
              color:
                  _obscure ? Colors.grey.shade700 : AppColors.brightTeal,
              onPressed: () {
                setState(() {
                  _obscure = !_obscure;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _strengthLabel,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _strengthColor,
          ),
        ),
        Text(
          '${_entropyBits.toStringAsFixed(1)} bits',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _strengthColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text(
          'Suggestions:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.midTeal, // requested colour
          ),
        ),
        const SizedBox(height: 8),
        ..._suggestions.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(
                  child: Text(
                    s,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ───────────── Gauge painter ───────────── */

class _StrengthMeterPainter extends CustomPainter {
  final double value; // 0–1
  final Color color;

  _StrengthMeterPainter({
    required this.value,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = min(size.width / 2 - 24, size.height * 0.8);

    final startAngle = pi;        // 180°
    final sweepAngle = pi;        // semi-circle

    final trackPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final valuePaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // background arc
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, trackPaint);

    // value arc
    canvas.drawArc(arcRect, startAngle, sweepAngle * value, false, valuePaint);

    // needle dot
    final needleAngle = startAngle + sweepAngle * value;
    final needleOffset = Offset(
      center.dx + radius * cos(needleAngle),
      center.dy + radius * sin(needleAngle),
    );
    canvas.drawCircle(
      needleOffset,
      6,
      Paint()..color = color,
    );

    // ─────────────────────────────────────────────
    // Labels 0 / 50 / 100 (placed UNDER the arc)
    // ─────────────────────────────────────────────
    TextPainter makeLabel(String text) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return tp;
    }

    final labelYOffset = 16.0; // how far below the arc the text sits

    final tp0 = makeLabel('0');
    tp0.paint(
      canvas,
      Offset(
        center.dx - radius - tp0.width / 2,
        center.dy + labelYOffset,
      ),
    );

    final tp100 = makeLabel('100');
    tp100.paint(
      canvas,
      Offset(
        center.dx + radius - tp100.width / 2,
        center.dy + labelYOffset,
      ),
    );

    final apexY = center.dy - radius; // top of the arc
    final tp50 = makeLabel('50');
    tp50.paint(
      canvas,
      Offset(center.dx - tp50.width / 2, apexY + 12), // +12 puts it under the bend
    );
  }

  @override
  bool shouldRepaint(covariant _StrengthMeterPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}