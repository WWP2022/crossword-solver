import 'package:crossword_solver/solveCrossword/crossword_solver.dart';
import 'package:crossword_solver/view/my_account.dart';
import 'package:crossword_solver/view/my_question_database.dart';
import 'package:crossword_solver/view/solve_crossword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'my_crosswords.dart';

class App extends StatelessWidget {
  static const String _title = 'Rozwiąż krzyżówkę';

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const SolveCrossword(),
    const MyQuestionDatabase(),
    const MyCrosswords(),
    const MyAccount(),
    const CrosswordSolverWidget()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Rozwiąż krzyżówkę'),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Colors.blue,
              primaryColor: Colors.red,
              textTheme: Theme.of(context)
                  .textTheme
                  .copyWith(caption: const TextStyle(color: Colors.yellow))),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.camera),
                label: 'Rozwiąż krzyżówkę',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.question_mark),
                label: 'Moja baza pytań',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'Moje rozwiązane krzyżówki',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Moje konto',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper),
                label: 'Rozwiązana krzyżówka',
              ),
            ],
            fixedColor: Colors.indigo,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            unselectedItemColor: Colors.black,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ));
  }
}
