import 'dart:io';

import 'package:crossword_solver/database/photoRepository.dart';
import 'package:flutter/material.dart';

import '../model/photo.dart';

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
        appBar: AppBar(title: const Text('Zdjęcie nierozwiązanej krzyżówki')),
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
                saveImage(widget.path, myController.text);
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

  saveImage(String path, String photoName) async {
    PhotoRepository photoRepository = PhotoRepository();
    Photo photo = Photo(path: path, name: photoName, date: DateTime.now());
    photoRepository.insertPhoto(photo);
  }
}
