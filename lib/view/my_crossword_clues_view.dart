import 'dart:convert';

import 'package:crossword_solver/util/http_util.dart';
import 'package:flutter/material.dart';

import '../model/crossword_clue.dart';
import '../util/loading_page_util.dart';
import '../util/prefs_util.dart';

class MyCrosswordClues extends StatefulWidget {
  const MyCrosswordClues({super.key});

  @override
  State<MyCrosswordClues> createState() => MyCrosswordCluesState();
}

class MyCrosswordCluesState extends State<MyCrosswordClues> {
  late Future<String> userId;
  late Future<List<CrosswordClue>> crosswordClues;
  late String question;
  late String answer;

  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userId = PrefsUtil.getUserId();
    crosswordClues = getCrosswordClues();
    resetControllers();
  }

  void resetControllers() {
    answerController.clear();
    questionController.clear();
    question = "";
    answer = "";
  }

  Future<List<CrosswordClue>> getCrosswordClues() async {
    var response = await HttpUtil.getAllCrosswordCluesByUserId(await userId);
    List<CrosswordClue> crosswordClues = <CrosswordClue>[];
    for (var clue in jsonDecode(response.body)) {
      CrosswordClue crosswordClue = decodeCrosswordClue(clue);
      crosswordClues.add(crosswordClue);
    }
    return crosswordClues;
  }

  decodeCrosswordClue(clue) {
    String question = clue["question"];
    String user_id = clue["user_id"];
    List<String> answers = <String>[];
    for (var answer in clue["answers"]) {
      answers.add(answer);
    }
    return CrosswordClue(answers, question, user_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<CrosswordClue>>(
        future: crosswordClues,
        builder: (context, clues) {
          if (clues.hasData) {
            return ListView(
                padding: const EdgeInsets.all(5),
                children: <Widget>[
                  for (var clue in clues.data!)
                    createCrosswordClueListView(context, clue),
                ]);
          } else {
            return LoadingPageUtil.buildLoadingPage();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            await displayTextInputDialog(context);
          }),
    );
  }

  Future<void> displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Dodaj nowe pytanie'),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.2,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextField(
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      setState(() {
                        question = value.toUpperCase();
                      });
                    },
                    controller: questionController,
                    decoration: const InputDecoration(hintText: "Podaj hasło"),
                  ),
                  TextField(
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      setState(() {
                        answer = value.toUpperCase();
                      });
                    },
                    controller: answerController,
                    decoration:
                    const InputDecoration(hintText: "Podaj odpowiedź"),
                  ),
                  //  TODO add button to add more inputs
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('ANULUJ'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: const Text('DODAJ'),
                onPressed: () async {
                  CrosswordClue crosswordClue = await createNewCrosswordClue();
                  (await crosswordClues).add(crosswordClue);
                  resetControllers();
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  ExpansionTile createCrosswordClueListView(
      BuildContext context, CrosswordClue clue) {
    return ExpansionTile(
        title: Text(clue.question), children: createAnswersView(clue.answers));
  }

  List<Widget> createAnswersView(List<String> answers) {
    List<Widget> answersWidgets = <Widget>[];
    for (var answer in answers) {
      answersWidgets.add(Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: ListTile(title: Text(answer))));
    }
    return answersWidgets;
  }

  Future<CrosswordClue> createNewCrosswordClue() async {
    String userId = await this.userId;
    CrosswordClue crosswordClue = CrosswordClue([answer], question, userId);
    HttpUtil.postCrosswordClue(crosswordClue);
    return crosswordClue;
  }
}
