// lib/src/models/question.dart
class QuestionBlock {
  final String stat;
  final List<SingleChoiceQuestion> questions;
  QuestionBlock({required this.stat, required this.questions});
}

class SingleChoiceQuestion {
  final String text;
  final Map<String, int> options;
  int? selectedValue;
  SingleChoiceQuestion({required this.text, required this.options});
}
