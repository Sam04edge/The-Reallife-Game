// lib/src/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'questionnaire_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'Willkommen bei\nTHE REALLIFE GAME',
      text:
          'Schluss mit dem tristen Alltag – mach dein echtes Leben zu einem Spiel! In THE REALLIFE GAME bist DU der Held deiner eigenen Geschichte.',
    ),
    OnboardingPage(
      title: 'So funktioniert\'s',
      text:
          'Erfülle tägliche, wöchentliche und monatliche Quests, um XP zu sammeln und dein Level sowie deine Werte zu verbessern.',
    ),
    OnboardingPage(
      title: 'Items & Motivation',
      text:
          'Es erwarten dich spannende Items, die dir beim Leveln helfen und deine Stats steigern.',
    ),
    OnboardingPage(
      title: 'Gemeinsam spielen',
      text:
          'Vergleiche dich mit Freunden und levelt gemeinsam durchs Leben. Hab Spaß und sei ehrlich zu dir selbst!',
    ),
    OnboardingPage(
      title: 'Das Wichtigste zum Schluss',
      text:
          'Sei ehrlich was deine Leistungen betrifft, nur so macht das Spiel Spaß! \nViel Spaß!!!',
    ),
  ];

  Future<void> _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenIntro', true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const QuestionnaireScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E1B0E),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (_, idx) => _pages[idx],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA70F0F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Los geht\'s!'
                        : 'Weiter',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String text;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4E0B5),
            border: Border.all(color: Colors.brown.shade800, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
