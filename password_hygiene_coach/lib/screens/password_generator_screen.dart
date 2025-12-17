import 'package:flutter/material.dart';
import '../widgets/password_generator.dart';
import '../utils/app_colours.dart';

class PasswordGeneratorScreen extends StatelessWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Palette
    const backgroundStart = Color(0xFF00254D);
    const backgroundEnd = Color(0xFF00A6B4);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: AppColors.brightTeal,      // replaces purple
          secondary: AppColors.midTeal,
        ),
        sliderTheme: SliderTheme.of(context).copyWith(
          activeTrackColor: AppColors.brightTeal,
          inactiveTrackColor: Colors.white54,
          thumbColor: AppColors.brightTeal,
          overlayColor: AppColors.brightTeal.withValues(alpha: 0.2),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brightTeal,
            foregroundColor: Colors.white,
          ),
        ),
      ),

      child: Scaffold(
        appBar: AppBar(
          title: const Text('Password Generator'),
          backgroundColor: backgroundStart,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundStart,
                backgroundEnd,
              ],
            ),
          ),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 110, 16, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 2000),
                  child: const PasswordGeneratorWidget(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}