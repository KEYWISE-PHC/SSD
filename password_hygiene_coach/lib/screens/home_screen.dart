import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password/screens/strength_feedback.dart';
import 'lesson_coach_screen.dart';
import 'password_generator_screen.dart';

/* ──────────────────────────────────────────────
   CUSTOM COLOR PALETTE (based on your image)
   ────────────────────────────────────────────── */
class AppColors {
  static const navy = Color(0xFF00254D);
  static const darkTeal = Color(0xFF00395E);
  static const midTeal = Color(0xFF005E70);
  static const brightTeal = Color(0xFF00A6B4);
  static const lightTurquoise = Color(0xFF4ED8E0);
  static const beige = Color(0xFFC5A27A);
}

/* ──────────────────────────────────────────────
   HOME SCREEN WITH PRIVACY OVERLAY
   ────────────────────────────────────────────── */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  bool _privacyOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Turn privacy screen on when app is not active, off when resumed.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      setState(() => _privacyOn = true);
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _privacyOn = false);
    }
  }

  void _openLessons() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LessonCoachScreen()),
    );
  }

  void _openGenerator() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PasswordGeneratorScreen()),
    );
  }

  void _openTester() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StrengthFeedbackScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final isMobile = size.width < 800;
    final textScaler = media.textScaler.clamp(maxScaleFactor: 1.4);

    final scaffold = Scaffold(
      extendBodyBehindAppBar: !isMobile,
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // On mobile: show hamburger (drawer). On wide: no drawer, logo in leading.
        leading: isMobile
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Semantics(
                  label: 'KeyWise app logo',
                  readOnly: true,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.darkTeal,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.lock_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
        title: Semantics(
          header: true,
          child: Text(
            'Password Hygiene Coach',
            textScaler: textScaler,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: false,
      ),

      // Drawer used as side navigation on mobile
      drawer: isMobile
          ? _SideDrawer(
              onHome: () => Navigator.pop(context),
              onLessons: () {
                Navigator.pop(context);
                _openLessons();
              },
              onGenerator: () {
                Navigator.pop(context);
                _openGenerator();
              },
              onTester: () {
                Navigator.pop(context);
                _openTester();
              },
            )
          : null,

      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.navy,
                  AppColors.darkTeal,
                  AppColors.midTeal,
                  AppColors.brightTeal,
                  AppColors.lightTurquoise,
                ],
                stops: [0.0, 0.25, 0.45, 0.7, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: isMobile
                ? _HomeContent(
                    textScaler: textScaler,
                    onLessons: _openLessons,
                    onGenerator: _openGenerator,
                    onTester: _openTester,
                  )
                : Row(
                    children: [
                      _SideNavRail(
                        selectedIndex: 0,
                        onHome: () {},
                        onLessons: _openLessons,
                        onGenerator: _openGenerator,
                        onTester: _openTester,
                      ),
                      const VerticalDivider(
                        width: 1,
                        color: Colors.white24,
                      ),
                      Expanded(
                        child: _HomeContent(
                          textScaler: textScaler,
                          onLessons: _openLessons,
                          onGenerator: _openGenerator,
                          onTester: _openTester,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );

    // Stack privacy overlay over the whole screen
    return Stack(
      children: [
        scaffold,
        if (_privacyOn) const _PrivacyOverlay(),
      ],
    );
  }
}

/* ──────────────────────────────────────────────
   PRIVACY OVERLAY (covers screen when app backgrounded)
   ────────────────────────────────────────────── */

class _PrivacyOverlay extends StatelessWidget {
  const _PrivacyOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true, // no interaction
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock_rounded, color: Colors.white, size: 48),
            SizedBox(height: 12),
            Text(
              'KeyWise hidden for privacy',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ──────────────────────────────────────────────
   SIDE NAVIGATION (WIDE SCREENS)
   ────────────────────────────────────────────── */

class _SideNavRail extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onHome;
  final VoidCallback onLessons;
  final VoidCallback onGenerator;
  final VoidCallback onTester;

  const _SideNavRail({
    required this.selectedIndex,
    required this.onHome,
    required this.onLessons,
    required this.onGenerator,
    required this.onTester,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Main navigation',
      child: NavigationRail(
        backgroundColor: AppColors.navy.withValues(alpha: 0.9),
        selectedIndex: selectedIndex,
        selectedIconTheme:
            const IconThemeData(color: Colors.white, size: 26),
        unselectedIconTheme:
            const IconThemeData(color: Colors.white70, size: 24),
        selectedLabelTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: Colors.white70,
        ),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              onHome();
              break;
            case 1:
              onLessons();
              break;
            case 2:
              onGenerator();
              break;
            case 3:
              onTester();
              break;
          }
        },
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: Text('Lessons'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.password_outlined),
            selectedIcon: Icon(Icons.password_rounded),
            label: Text('Generator'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.security_outlined),
            selectedIcon: Icon(Icons.security_rounded),
            label: Text('Tester'),
          ),
        ],
      ),
    );
  }
}

/* ──────────────────────────────────────────────
   SIDE DRAWER (MOBILE)
   ────────────────────────────────────────────── */

class _SideDrawer extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onLessons;
  final VoidCallback onGenerator;
  final VoidCallback onTester;

  const _SideDrawer({
    required this.onHome,
    required this.onLessons,
    required this.onGenerator,
    required this.onTester,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScaler = media.textScaler.clamp(maxScaleFactor: 1.4);

    return Drawer(
      child: Container(
        color: AppColors.navy,
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.lock_rounded, color: Colors.white),
                title: Text(
                  'KeyWise',
                  textScaler: textScaler,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'Password Hygiene Coach',
                  textScaler: textScaler,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
              const Divider(color: Colors.white24),
              _DrawerItem(
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: onHome,
              ),
              _DrawerItem(
                icon: Icons.menu_book_rounded,
                label: 'Lessons',
                onTap: onLessons,
              ),
              _DrawerItem(
                icon: Icons.password_rounded,
                label: 'Password Generator',
                onTap: onGenerator,
              ),
              _DrawerItem(
                icon: Icons.security_rounded,
                label: 'Strength Tester',
                onTap: onTester,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScaler = media.textScaler.clamp(maxScaleFactor: 1.4);

    return Semantics(
      button: true,
      label: label,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          textScaler: textScaler,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

/* ──────────────────────────────────────────────
   MAIN HOME CONTENT (HERO + FEATURE CARDS)
   ────────────────────────────────────────────── */

class _HomeContent extends StatelessWidget {
  final TextScaler textScaler;
  final VoidCallback onLessons;
  final VoidCallback onGenerator;
  final VoidCallback onTester;

  const _HomeContent({
    required this.textScaler,
    required this.onLessons,
    required this.onGenerator,
    required this.onTester,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final logoDiameter = isWide
            ? 320.0
            : (constraints.maxWidth < 380 ? 200.0 : 240.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HERO SECTION
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Semantics(
                              label:
                                  'KeyWise logo, password hygiene coach',
                              readOnly: true,
                              child: _BigLogo(diameter: logoDiameter),
                            ),
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: _TextPanel(
                            child: Padding(
                              padding: const EdgeInsets.all(22),
                              child: Text(
                                'Welcome to KeyWise, a password hygiene coach application that helps you learn, build, and maintain strong and secure passwords. Through interactive lessons, quizzes, and tools like a password generator and strength tester, KeyWise guides you toward safer online habits and better digital security.',
                                textScaler: textScaler,
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Semantics(
                          label:
                              'KeyWise logo, password hygiene coach',
                          readOnly: true,
                          child: _BigLogo(diameter: logoDiameter),
                        ),
                        const SizedBox(height: 20),
                        _TextPanel(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Text(
                              'Welcome to KeyWise, a password hygiene coach application that helps you learn, build, and maintain strong and secure passwords.',
                              textScaler: textScaler,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize:
                                    size.width < 360 ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 28),

                  // FEATURE CARDS
                  LayoutBuilder(
                    builder: (_, c) {
                      final isWideGrid = isWide || c.maxWidth > 560;
                      final ratio = isWideGrid ? 16 / 6 : 16 / 5;

                      return GridView.count(
                        crossAxisCount: isWideGrid ? 2 : 1,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: ratio,
                        children: [
                          _FeatureCard(
                            color: AppColors.navy,
                            icon: Icons.menu_book_rounded,
                            title: 'Lessons & Quizzes',
                            subtitle:
                                'Learn the essentials and test yourself',
                            onTap: onLessons,
                          ),
                          _FeatureCard(
                            color: AppColors.midTeal,
                            icon: Icons.password_rounded,
                            title: 'Password Generator',
                            subtitle:
                                'Create strong, unique passwords instantly',
                            onTap: onGenerator,
                          ),
                          _FeatureCard(
                            color: AppColors.brightTeal,
                            icon: Icons.security_rounded,
                            title: 'Strength Tester',
                            subtitle:
                                'Check how secure your passwords really are',
                            onTap: onTester,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ──────────────────────────────────────────────
   LOGO
   ────────────────────────────────────────────── */

class _BigLogo extends StatelessWidget {
  final double diameter;

  const _BigLogo({required this.diameter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.error, size: 100, color: Colors.white),
        ),
      ),
    );
  }
}

/* ──────────────────────────────────────────────
   TEXT PANEL
   ────────────────────────────────────────────── */

class _TextPanel extends StatelessWidget {
  final Widget child;

  const _TextPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white70),
      ),
      child: child,
    );
  }
}

/* ──────────────────────────────────────────────
   FEATURE CARD (ACCESSIBLE)
   ────────────────────────────────────────────── */

class _FeatureCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    final onColor =
        brightness == Brightness.dark ? Colors.white : Colors.black87;
    final media = MediaQuery.of(context);
    final textScaler = media.textScaler.clamp(maxScaleFactor: 1.4);

    return Semantics(
      button: true,
      label: title,
      hint: subtitle,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: onColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 28, color: onColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: onColor),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          textScaler: textScaler,
                          style: TextStyle(
                            color: onColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          textScaler: textScaler,
                          style: TextStyle(
                            color: onColor.withValues(alpha: 0.95),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 18, color: onColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
