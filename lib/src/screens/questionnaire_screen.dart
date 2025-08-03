// lib/src/screens/questionnaire_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/question.dart';
import 'home_screen.dart'; // statt MainScreen importieren

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({Key? key}) : super(key: key);

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final List<QuestionBlock> questions = [
    QuestionBlock(
      stat: 'Weisheit',
      questions: [
        SingleChoiceQuestion(
          text: 'Wie viele Bücher liest du pro Monat?',
          options: {'Keine': 0, '1 Buch': 1, '2 Bücher': 2, '3+ Bücher': 3},
        ),
        SingleChoiceQuestion(
          text: 'Wie oft bildest du dich aktiv weiter?',
          options: {'Nie': 0, 'Selten': 1, 'Wöchentlich': 2},
        ),
      ],
    ),
    QuestionBlock(
      stat: 'Stärke',
      questions: [
        SingleChoiceQuestion(
          text: 'Wie oft trainierst du pro Woche?',
          options: {'Nie': 0, '1x': 1, '2–3x': 2, '4x+': 3},
        ),
        SingleChoiceQuestion(
          text: 'Wie schätzt du deine körperliche Fitness ein?',
          options: {'Schlecht': 0, 'Durchschnitt': 1, 'Gut': 2},
        ),
      ],
    ),
    QuestionBlock(
      stat: 'Ausdauer',
      questions: [
        SingleChoiceQuestion(
          text: 'Wie lange hältst du bei einem Ausdauerlauf durch?',
          options: {
            '<15 Min': 0,
            '15–30 Min': 1,
            '30–45 Min': 2,
            '45–60 Min': 3,
          },
        ),
        SingleChoiceQuestion(
          text: 'Wie oft gibst du auf, wenn es hart wird?',
          options: {'Oft': 0, 'Manchmal': 1, 'Selten': 2},
        ),
      ],
    ),
    QuestionBlock(
      stat: 'Charisma',
      questions: [
        SingleChoiceQuestion(
          text: 'Wie leicht lernst du neue Leute kennen?',
          options: {'Schwer': 0, 'OK': 1, 'Leicht': 2},
        ),
        SingleChoiceQuestion(
          text: 'Wie wohl fühlst du dich vor Gruppen?',
          options: {'Unwohl': 0, 'Neutral': 1, 'Sicher': 2},
        ),
      ],
    ),
    QuestionBlock(
      stat: 'Glück',
      questions: [
        SingleChoiceQuestion(
          text: 'Wie oft hast du Glück in Zufallsspielen?',
          options: {'Nie': 0, 'Selten': 1, 'Manchmal': 2, 'Oft': 3},
        ),
        SingleChoiceQuestion(
          text: 'Fällt dir oft etwas Positives zu?',
          options: {'Nie': 0, 'Selten': 1, 'Manchmal': 2},
        ),
      ],
    ),
  ];

  Future<void> _completeQuestionnaire() async {
    final prefs = await SharedPreferences.getInstance();
    for (final block in questions) {
      int total =
          block.questions.fold(0, (sum, q) => sum + (q.selectedValue ?? 0));
      await prefs.setInt('stat_${block.stat}', total);
    }
    await prefs.setBool('completedQuestionnaire', true);
    await prefs.setInt('level', 1);
    await prefs.setDouble('exp', 0);
    if (!mounted) return;
    // Hier HomeScreen statt MainScreen aufrufen:
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dein Fragebogen'),
        backgroundColor: Colors.brown.shade700,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Beantworte die folgenden Fragen ehrlich:',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ...questions.expand((block) => [
                Text(block.stat,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...block.questions.map((q) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.text,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        ...q.options.entries.map((e) => RadioListTile<int>(
                              title: Text(e.key),
                              value: e.value,
                              groupValue: q.selectedValue,
                              onChanged: (v) =>
                                  setState(() => q.selectedValue = v),
                            )),
                        const SizedBox(height: 10),
                      ],
                    )),
                const Divider(thickness: 2, height: 30),
              ]),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA70F0F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _completeQuestionnaire,
            child: const Text('Fertig', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
