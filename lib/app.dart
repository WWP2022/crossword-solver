import 'package:crossword_solver/auth/pages/user_page.dart';
import 'package:crossword_solver/crossword_clues/pages/crossword_clues_page.dart';
import 'package:crossword_solver/solve_crossword/pages/solve_crossword_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'crosswords/pages/crosswords_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Rozwiąż krzyżówkę",
      home: AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  int _selectedIndex = 0;
  String _title = "Rozwiąż krzyżówkę";

  static final List<Widget> _widgetOptions = <Widget>[
    const SolveCrossword(),
    const CrosswordCluesPage(),
    const CrosswordsPage(),
    const UserPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          {
            _title = "Rozwiąż krzyżówkę";
          }
          break;
        case 1:
          {
            _title = "Moja baza pytań";
          }
          break;
        case 2:
          {
            _title = "Moje krzyżówki";
          }
          break;
        case 3:
          {
            _title = "Moje konto";
          }
          break;
      }
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
          title: Text(_title),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
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
                label: 'Moje krzyżówki',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Moje konto',
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
