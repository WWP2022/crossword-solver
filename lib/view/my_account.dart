import 'package:flutter/cupertino.dart';

class MyAccount extends StatelessWidget {
  const MyAccount({super.key});

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Moje konto',
      style: optionStyle,
    );
  }
}
