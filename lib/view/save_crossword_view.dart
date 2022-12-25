import 'dart:convert';
import 'dart:io';

import 'package:crossword_solver/database/crossword_info_repository.dart';
import 'package:crossword_solver/util/http_util.dart';
import 'package:crossword_solver/util/prefs_util.dart';
import 'package:flutter/material.dart';

import '../model/crossword_info.dart';

class SaveCrossword extends StatefulWidget {
  final String path;
  final String id;
  final String name;

  const SaveCrossword({Key? key, required this.path, required this.id, required this.name}) : super(key: key);

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
    myController.text = widget.name;
    return Scaffold(
        appBar: AppBar(title: const Text('Zdjęcie rozwiązanej krzyżówki')),
        body: Column(children: <Widget>[
          SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                alignLabelWithHint: true,
              ),
              controller: myController,
            ),
          ),
          Expanded(
            flex: 300,
            child: Image.file(File(widget.path)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              rejectCrosswordButton(),
              skipCrosswordButton(),
              approveCrosswordButton()
            ],
          )
        ]));
  }


  TextButton rejectCrosswordButton() {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
      ),
      onPressed: () async {
        var userId = await PrefsUtil.getUserId();

        var response = await HttpUtil.updateCrossword(
            userId,
            widget.id,
            isAccepted: false
        );

        var decodedResponse = jsonDecode(response.body);

        if (response.statusCode == 201) {
          deleteImage(int.parse(widget.id));
        } else {
          print("error: " + decodedResponse['error']);
        }
        Navigator.pop(context, true);
      },
      child: const Text('Odrzuć'),
    );
  }

  TextButton skipCrosswordButton() {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.grey),
      ),
      onPressed: () async {
        Navigator.pop(context, true);
      },
      child: const Text('Pomiń'),
    );
  }

  TextButton approveCrosswordButton() {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.green),
      ),
      onPressed: () async {
        String crosswordName = myController.text;
        if (crosswordName.isEmpty) {
          showEmptyNameAlert(context);
        } else {
          var userId = await PrefsUtil.getUserId();

          var response;
          if (widget.name != crosswordName) {
            response = await HttpUtil.updateCrossword(
                userId,
                widget.id,
                isAccepted: true,
                crosswordName: crosswordName
            );
          } else {
            response = await HttpUtil.updateCrossword(
                userId,
                widget.id,
                isAccepted: true,
            );
          }

          var decodedResponse = jsonDecode(response.body);

          if (response.statusCode == 201) {
            saveAcceptedImage(
                int.parse(widget.id),
                widget.path,
                decodedResponse['crossword_name'],
                decodedResponse['user_id'],
                decodedResponse['status']
            );
          } else {
            print("error: " + decodedResponse['error']);
          }
          Navigator.pop(context, true);
        }
      },
      child: const Text('Potwierdź'),
    );
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

  void saveAcceptedImage(
      int id, String path, String crosswordName, String userId, String status) async {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    CrosswordInfo crosswordInfo = CrosswordInfo(
        id: id,
        path: path,
        crosswordName: crosswordName,
        timestamp: DateTime.now(),
        userId: userId,
        status: status);
    await crosswordInfoRepository.insertCrosswordInfo(crosswordInfo);
  }

  void deleteImage(int id) async {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    await crosswordInfoRepository.deleteCrosswordInfo(id);
  }
}
