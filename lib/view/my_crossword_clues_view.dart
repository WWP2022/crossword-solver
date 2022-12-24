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

  //TODO think of better way to control height of alert dialog
  late double alertDialogHeight;

  final TextEditingController questionController = TextEditingController();
  List<TextEditingController> answerControllers = [];
  List<TextField> answerTextFields = [];

  @override
  void initState() {
    userId = PrefsUtil.getUserId();
    crosswordClues = getCrosswordClues();
    resetControllers();
    super.initState();
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

  //TODO bug: can add only one question (have to quit view, then work good)
  void resetControllers() {
    questionController.clear();
    for (var answerController in answerControllers) {
      answerController.clear();
    }
    answerControllers = <TextEditingController>[];
    initializeOneAnswerTextField();
    alertDialogHeight = 2 / 9;
  }

  void initializeOneAnswerTextField() {
    TextEditingController controller = TextEditingController();
    controller.clear();
    TextField field = createTextField(controller, "Podaj odpowiedź");
    answerControllers.add(controller);
    answerTextFields.add(field);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<CrosswordClue>>(
        future: crosswordClues,
        builder: (context, clues) {
          if (clues.hasData) {
            return ListView(children: <Widget>[
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
          onPressed: () {
            displayTextInputDialog(context);
          }),
    );
  }

  ExpansionTile createCrosswordClueListView(
      BuildContext context, CrosswordClue clue) {
    //TODO allow edit and delete clue
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

  displayTextInputDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 2.0),
              title: Transform.translate(
                offset: const Offset(0, -16),
                child: const Text('Dodaj nowe pytanie'),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.99,
                height: MediaQuery.of(context).size.height * alertDialogHeight,
                child: Column(children: [
                  createQuestionTextField(),
                  Expanded(child: createAnswerTextFields()),
                  addAnswerButton(setState),
                ]),
              ),
              actions: createButtonsInAlertDialog(),
              actionsPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
            );
          });
        });
  }

  TextField createQuestionTextField() {
    return TextField(
      textCapitalization: TextCapitalization.characters,
      controller: questionController,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Podaj hasło",
          contentPadding: EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 2.0)),
      onEditingComplete: () {
        setState(() {
          questionController.text.toUpperCase();
        });
      },
    );
  }

  TextField createTextField(TextEditingController controller, String hintText) {
    return TextField(
      textCapitalization: TextCapitalization.characters,
      controller: controller,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
          contentPadding: const EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 2.0)),
      onEditingComplete: () {
        setState(() {
          controller.text.toUpperCase();
        });
      },
    );
  }

  Widget createAnswerTextFields() {
    return ListView.builder(
      itemCount: answerControllers.length,
      itemBuilder: (context, index) {
        return Container(
          child: answerTextFields[index],
        );
      },
    );
  }

  //TODO allow also to remove added text field
  Widget addAnswerButton(setState) {
    return ListTile(
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      title: const Icon(Icons.add),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        final controller = TextEditingController();
        final field = createTextField(controller, "Podaj odpowiedź");
        setState(() {
          answerControllers.add(controller);
          answerTextFields.add(field);
          alertDialogHeight = answerControllers.length / 9;
        });
      },
    );
  }

  List<Widget> createButtonsInAlertDialog() {
    return <Widget>[
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
          if (isQuestionOrAnswerEmpty()) {
            showEmptyNameAlert(context);
          } else if (await isQuestionAlreadyPresent()) {
            showQuestionAlreadyExistsAlert(context);
          } else {
            await createNewCrosswordClue();
            setState(() {
              crosswordClues = getCrosswordClues();
              resetControllers();
              Navigator.pop(context);
            });
          }
        },
      ),
    ];
  }

  bool isQuestionOrAnswerEmpty() {
    bool isQuestionEmpty = questionController.text.isEmpty;
    bool isAnswerEmpty = answerControllers
        .every((answerController) => answerController.text.isEmpty);

    return isQuestionEmpty || isAnswerEmpty;
  }

  Future<bool> isQuestionAlreadyPresent() async {
    String question = questionController.text;
    return (await crosswordClues)
        .any((crosswordClue) => crosswordClue.question == question);
  }

  void showEmptyNameAlert(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Nie udało się dodać hasła!"),
      content: const Text("Pytanie oraz odpowiedź muszą zostać uzupełnione"),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showQuestionAlreadyExistsAlert(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Nie udało się dodać hasła!"),
      content: const Text("Pytanie istnieje już w bazie"),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<CrosswordClue> createNewCrosswordClue() async {
    String userId = await this.userId;
    List<String> answers = [];
    for (var controller in answerControllers) {
      if (controller.text.isNotEmpty) {
        answers.add(controller.text);
      }
    }
    CrosswordClue crosswordClue =
        CrosswordClue(answers, questionController.text, userId);
    HttpUtil.postCrosswordClue(crosswordClue);
    return crosswordClue;
  }
}
