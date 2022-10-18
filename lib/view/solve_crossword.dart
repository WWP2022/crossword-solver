import 'package:flutter/cupertino.dart';

class SolveCrossword extends StatelessWidget {
  const SolveCrossword({super.key});

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Rozwiąż krzyżówkę',
      style: optionStyle,
    );
  }
}
