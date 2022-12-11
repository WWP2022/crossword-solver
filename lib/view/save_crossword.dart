import 'dart:io';

import 'package:crossword_solver/database/crossword_info_repository.dart';
import 'package:crossword_solver/util/prefs_util.dart';
import 'package:flutter/material.dart';

import '../model/crossword_info.dart';

class SaveCrossword extends StatefulWidget {
  final String path;

  const SaveCrossword({Key? key, required this.path}) : super(key: key);

  @override
  State<SaveCrossword> createState() => _SaveCrossword();
}

class _SaveCrossword extends State<SaveCrossword> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Zdjęcie rozwiązanej krzyżówki')),
        body: Column(children: <Widget>[
          SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Nazwa krzyżówki',
                alignLabelWithHint: true,
              ),
              controller: myController,
            ),
          ),
          Expanded(
            flex: 300,
            child: Image.file(File(widget.path)),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () async {
              String photoName = myController.text;
              if (photoName.isEmpty) {
                showEmptyNameAlert(context);
              } else {
                saveImage(
                    123, widget.path, photoName, await PrefsUtil.getUserId());
                Navigator.pop(context, true);
              }
            },
            child: const Text('Zapisz zdjęcie'),
          )
        ]));
  }

  void showEmptyNameAlert(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Nie udało się zapisać krzyżówki!"),
      content: const Text("Nazwa krzyżówki nie może być pusta"),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void saveImage(
      int id, String path, String crosswordName, String userId) async {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    CrosswordInfo crosswordInfo = CrosswordInfo(
        id: id,
        path: path,
        crosswordName: crosswordName,
        timestamp: DateTime.now(),
        userId: userId,
        status: "new");
    crosswordInfoRepository.insertCrosswordInfo(crosswordInfo);
  }
}
