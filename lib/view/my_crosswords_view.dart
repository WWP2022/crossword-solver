import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crossword_solver/util/http_util.dart';
import 'package:crossword_solver/util/loading_page_util.dart';
import 'package:crossword_solver/util/prefs_util.dart';
import 'package:crossword_solver/view/save_crossword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../database/crossword_info_repository.dart';
import '../model/crossword_info.dart';

class MyCrosswords extends StatefulWidget {
  const MyCrosswords({super.key});

  @override
  State<MyCrosswords> createState() => MyCrosswordsState();
}

class MyCrosswordsState extends State<MyCrosswords> {
  late List<CrosswordInfo> crosswordsInfo;

  @override
  void initState() {
    super.initState();
    getPhotos();
  }

  void refreshState() {
    getPhotos();
  }

  getPhotos() async {
    CrosswordInfoRepository photoRepository = CrosswordInfoRepository();
    var userId = await PrefsUtil.getUserId();
    crosswordsInfo = await photoRepository.getAllCrosswordsInfo(userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CrosswordInfo>>(
        future: getImages(),
        builder: (context, crosswordsInfo) {
          if (crosswordsInfo.hasData) {
            var crosswordsInfoSorted = crosswordsInfo.data!;
            crosswordsInfoSorted.sort((a, b) {
              int statusComp = -a.status.compareTo(b.status);
              if (statusComp == 0) {
                return a.crosswordName.compareTo(b.crosswordName);
              }
              return statusComp;
            });
            return ListView(
                padding: const EdgeInsets.all(5),
                children: <Widget>[
                  for (var crosswordInfo in crosswordsInfoSorted)
                    createCrosswordList(context, crosswordInfo),
                ]);
          } else {
            return LoadingPageUtil.buildLoadingPage();
          }
        });
  }

  Future<List<CrosswordInfo>> getImages() async {
    CrosswordInfoRepository photoRepository = CrosswordInfoRepository();
    var userId = await PrefsUtil.getUserId();
    List<CrosswordInfo> photos = await photoRepository.getAllCrosswordsInfo(userId);
    return photos;
  }

  Container createCrosswordList(
      BuildContext context, CrosswordInfo crosswordInfo) {
    Image image = Image.file(File(crosswordInfo.path));

    var color = Colors.white;
    if (crosswordInfo.status == "solved_waiting") {
      color = Colors.orange;
    }

    return Container(
        color: color,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Expanded(flex: 25, child: SizedBox()),
          buildClickableImage(crosswordInfo, image),
          const Expanded(flex: 25, child: SizedBox()),
          buildClickableCrosswordName(crosswordInfo, image),
          const Expanded(flex: 25, child: SizedBox()),
          buildDateInProperFormat(crosswordInfo.timestamp),
          const Expanded(flex: 25, child: SizedBox()),
          buildRemoveButton(crosswordInfo),
        ]));
  }

  Expanded buildClickableImage(CrosswordInfo crosswordInfo, Image image) {
    return Expanded(
        flex: 300,
        child: GestureDetector(
          child: image,
          onTap: () {
            modifyNameOrSaveCrossword(crosswordInfo, image);
          },
        ));
  }

  Expanded buildClickableCrosswordName(
      CrosswordInfo crosswordInfo, Image image) {
    return Expanded(
        flex: 300,
        child: GestureDetector(
          child: Text(crosswordInfo.crosswordName),
          onTap: () {
            modifyNameOrSaveCrossword(crosswordInfo, image);
          },
        ));
  }

  void modifyNameOrSaveCrossword(CrosswordInfo crosswordInfo, Image image) {
    if (crosswordInfo.status == "solved_waiting") {
      navigateToSaveCrossword(crosswordInfo);
    } else {
      navigateToModifyCrosswordNameScreen(crosswordInfo, image);
    }
  }

  void navigateToModifyCrosswordNameScreen(
      CrosswordInfo crosswordInfo, Image image) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ModifyCrosswordNameScreen(crosswordInfo, image);
    })).then((value) => {
          if (value == true) {refreshState()}
        });
  }

  void navigateToSaveCrossword(CrosswordInfo crosswordInfo) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return SaveCrossword(
          path: crosswordInfo.path,
          id: crosswordInfo.id.toString(),
          name: crosswordInfo.crosswordName);
    })).then((value) => {
          if (value == true) {refreshState()}
        });
  }

  Expanded buildDateInProperFormat(DateTime dateTime) {
    DateFormat format = DateFormat('yyyy-MM-dd\nhh:mm');
    return Expanded(flex: 300, child: Text(format.format(dateTime)));
  }

  Expanded buildRemoveButton(CrosswordInfo photo) {
    return Expanded(
      flex: 300,
      child: IconButton(
        onPressed: () {
          showDeletionAlert(context, photo);
        },
        icon: const Icon(
          Icons.delete,
          size: 40.0,
          color: Colors.red,
        ),
      ),
    );
  }

  void showDeletionAlert(BuildContext context, CrosswordInfo crosswordInfo) {
    Widget okButton = TextButton(
      child: const Text("Usuń"),
      onPressed: () async {
        setState(() {
          crosswordsInfo.remove(crosswordInfo);
        });

        var response = await HttpUtil.deleteCrossword(
            crosswordInfo.userId, crosswordInfo.id.toString());

        if (response.statusCode == 204) {
          removeImage(crosswordInfo.id);
        } else {
          var decodedResponse = jsonDecode(response.body);
          print("error: " + decodedResponse['error']);
        }

        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Anuluj"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Czy na pewno chcesz usunąć krzyżówkę?"),
      actions: [okButton, cancelButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void removeImage(int id) async {
    CrosswordInfoRepository photoRepository = CrosswordInfoRepository();
    await photoRepository.deleteCrosswordInfo(id);
  }
}

class ModifyCrosswordNameScreen extends StatefulWidget {
  final CrosswordInfo crosswordInfo;
  final Image image;

  const ModifyCrosswordNameScreen(this.crosswordInfo, this.image, {super.key});

  @override
  ModifyCrosswordNameScreenState createState() =>
      ModifyCrosswordNameScreenState();
}

class ModifyCrosswordNameScreenState extends State<ModifyCrosswordNameScreen> {
  final modifyCrosswordNameController = TextEditingController();

  @override
  initState() {
    super.initState();
    modifyCrosswordNameController.text = widget.crosswordInfo.crosswordName;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    modifyCrosswordNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Zmodyfikuj nazwę krzyżówki')),
        body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Colors.black),
                        ),
                        alignLabelWithHint: true,
                      ),
                      controller: modifyCrosswordNameController,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: () async {
                        String newCrosswordName =
                            modifyCrosswordNameController.text;
                        if (await isCrosswordNameWrong(
                            widget.crosswordInfo.crosswordName,
                            newCrosswordName)) {
                          showEmptyNameAlert(context);
                        } else {
                          var response = await HttpUtil.updateCrossword(
                              widget.crosswordInfo.userId,
                              widget.crosswordInfo.id.toString(),
                              crosswordName: newCrosswordName,
                              isAccepted: true);

                          var decodedResponse = jsonDecode(response.body);

                          if (response.statusCode == 201) {
                            saveCrosswordName(
                                widget.crosswordInfo, newCrosswordName);
                          } else {
                            print("error: " + decodedResponse['error']);
                          }

                          Navigator.pop(context, true);
                        }
                      },
                      child: const Icon(Icons.check),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      onPressed: () => {
                        Navigator.pop(context, false),
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  // width: MediaQuery.of(context).size.width,
                  child: Center(
                      heightFactor: MediaQuery.of(context).size.height,
                      widthFactor: 0.5,
                      child: widget.image),
                ),
              ],
            )));
  }

  void showEmptyNameAlert(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Nie udało się zapisać zmiany nazwy krzyżówki!"),
      content: const Text(
          "Nazwa krzyżówki nie może być pusta lub identyczna z już istniejącą."),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void saveCrosswordName(CrosswordInfo crosswordInfo, String text) {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    crosswordInfo.crosswordName = text;
    crosswordInfoRepository.updateCrosswordInfo(crosswordInfo);
  }

  Future<bool> isCrosswordNameWrong(
      String oldCrosswordName, String newCrosswordName) async {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    var userId = await PrefsUtil.getUserId();
    List<CrosswordInfo> crosswordsInfo =
        await crosswordInfoRepository.getAllCrosswordsInfo(userId);
    if (crosswordsInfo
        .map((crosswordInfo) => crosswordInfo.crosswordName)
        .contains(newCrosswordName)) {
      return true;
    }
    if (newCrosswordName.isEmpty) {
      return true;
    }
    return false;
  }
}

class DetailScreen extends StatefulWidget {
  final Image image;

  const DetailScreen(this.image, {super.key});

  get getImage => image;

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  @override
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(child: widget.image),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
