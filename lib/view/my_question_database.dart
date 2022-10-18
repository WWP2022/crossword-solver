import 'package:flutter/cupertino.dart';

class MyQuestionDatabase extends StatelessWidget {
  const MyQuestionDatabase({super.key});

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Moja baza pytań',
      style: optionStyle,
    );
  }
}
