import 'dart:convert';

import 'package:crossword_solver/core/utils/http_util.dart';
import 'package:crossword_solver/core/utils/loading_page_util.dart';
import 'package:crossword_solver/core/utils/prefs_util.dart';
import 'package:crossword_solver/model/crossword_clue.dart';
import 'package:flutter/material.dart';

class CrosswordCluesPage extends StatefulWidget {
  const CrosswordCluesPage({super.key});

  @override
  State<CrosswordCluesPage> createState() => CrosswordCluesPageState();
}

class CrosswordCluesPageState extends State<CrosswordCluesPage> {
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

  void resetControllers() {
    questionController.clear();
    for (var answerController in answerControllers) {
      answerController.clear();
    }
    answerControllers = <TextEditingController>[];
    answerTextFields = <TextField>[];
    initializeOneAnswerTextField();
    alertDialogHeight = 0.1 + 1 / 9;
  }

  void initializeOneAnswerTextField() {
    TextEditingController controller = TextEditingController();
    controller.clear();
    TextField field = createTextField(controller, "PODAJ ODPOWIEDŹ");
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
            return showCrosswordClues(setState, clues.data!);
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

  Widget showCrosswordClues(
      StateSetter setState, List<CrosswordClue> crosswordCluesToShow) {
    if (crosswordCluesToShow.isEmpty) {
      return const Center(
          child: Text('BRAK HASEŁ', textAlign: TextAlign.center));
    } else {
      return ListView(children: <Widget>[
        for (var clue in crosswordCluesToShow)
          createCrosswordClueListView(context, setState, clue),
      ]);
    }
  }

  Row createCrosswordClueListView(
      BuildContext context, StateSetter setState, CrosswordClue clue) {
    //TODO allow edit
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      buildCrosswordClue(clue),
      buildRemoveButton(context, setState, clue)
    ]);
  }

  Expanded buildCrosswordClue(CrosswordClue clue) {
    return Expanded(
        flex: 4,
        child: ExpansionTile(
            title: Text(clue.question),
            children: createAnswersView(clue.answers)));
  }

  Expanded buildRemoveButton(
      BuildContext context, StateSetter setState, CrosswordClue clue) {
    return Expanded(
      flex: 1,
      child: IconButton(
        onPressed: () {
          displayRemoveClueDialog(context, clue);
        },
        icon: const Icon(
          Icons.delete,
          size: 40.0,
          color: Colors.red,
        ),
      ),
    );
  }

  Future displayRemoveClueDialog(BuildContext context, CrosswordClue clue) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 2.0),
              title: Transform.translate(
                offset: const Offset(0, -16),
                child: const Text('CZY NA PEWNO CHCESZ USUNĄĆ PYTANIE?'),
              ),
              actions: createButtonsInRemoveClueDialog(context, clue),
              actionsPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
            );
          });
        });
  }

  List<Widget> createButtonsInRemoveClueDialog(
      BuildContext context, CrosswordClue clue) {
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
          child: const Text('USUŃ'),
          onPressed: () async {
            await HttpUtil.deleteCrosswordClue(await userId, clue.question);
            setState(() {
              crosswordClues = getCrosswordClues();
              Navigator.pop(context);
            });
          }),
    ];
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

  Future displayTextInputDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 2.0),
              title: Transform.translate(
                offset: const Offset(0, -16),
                child: const Text('DODAJ NOWE PYTANIE'),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.99,
                height: MediaQuery.of(context).size.height * alertDialogHeight,
                child: Column(children: [
                  createQuestionTextField(),
                  Expanded(child: displayAnswerTextFields(context, setState)),
                  addAnswerButton(setState),
                ]),
              ),
              actions: createButtonsInAlertDialog(context),
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
          hintText: "PODAJ HASŁO",
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

  Widget displayAnswerTextFields(BuildContext context, StateSetter setState) {
    return ListView.builder(
      itemCount: answerControllers.length,
      itemBuilder: (context, index) {
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(flex: 3, child: answerTextFields[index]),
          buildRemoveButtonForAnswerFields(
              context, setState, answerTextFields[index])
        ]);
      },
    );
  }

  Expanded buildRemoveButtonForAnswerFields(
      BuildContext context, StateSetter setState, TextField answerTextField) {
    return Expanded(
      flex: 1,
      child: IconButton(
        onPressed: () {
          setState(() {
            TextEditingController controller = answerTextField.controller!;
            controller.clear();
            answerControllers.remove(controller);
            answerTextFields.remove(answerTextField);
            if (answerControllers.isEmpty) {
              alertDialogHeight = 0.1 + 1 / 9;
            } else {
              alertDialogHeight = 0.1 + answerControllers.length / 9;
            }
          });
        },
        icon: const Icon(
          Icons.delete,
          size: 40.0,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget addAnswerButton(setState) {
    return ListTile(
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      title: const Icon(Icons.add),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        final controller = TextEditingController();
        final field = createTextField(controller, "PODAJ ODPOWIEDŹ");
        setState(() {
          answerControllers.add(controller);
          answerTextFields.add(field);
          alertDialogHeight = 0.1 + answerControllers.length / 9;
        });
      },
    );
  }

  List<Widget> createButtonsInAlertDialog(BuildContext context) {
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
      title: const Text("NIE UDAŁO SIĘ DODAĆ HASŁA!"),
      content: const Text("PYTANIE ORAZ ODPOWIEDŹ MUSZĄ ZOSTAĆ UZUPEŁNIONE"),
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
      title: const Text("NIE UDAŁO SIĘ DODAĆ HASŁA!"),
      content: const Text("PYTANIE ISTNIEJE JUŻ W BAZIE"),
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
    await HttpUtil.postCrosswordClue(crosswordClue);
    return crosswordClue;
  }
}
