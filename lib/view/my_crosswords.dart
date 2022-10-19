import 'package:flutter/cupertino.dart';

class MyCrosswords extends StatelessWidget {
  const MyCrosswords({super.key});

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Moje rozwiązane krzyżówki',
      textAlign: TextAlign.center,
      style: optionStyle,
    );
  }
}
