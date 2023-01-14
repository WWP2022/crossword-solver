import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crossword_solver/core/utils/http_util.dart';
import 'package:crossword_solver/core/utils/loading_page_util.dart';
import 'package:crossword_solver/core/utils/prefs_util.dart';
import 'package:crossword_solver/database/crossword_info_repository.dart';
import 'package:crossword_solver/model/crossword_info.dart';
import 'package:crossword_solver/save_crossword_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CrosswordsPage extends StatefulWidget {
  const CrosswordsPage({super.key});

  @override
  State<CrosswordsPage> createState() => CrosswordsPageState();
}

class CrosswordsPageState extends State<CrosswordsPage> {
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
            return showCrosswords(crosswordsInfo.data!);
          } else {
            return LoadingPageUtil.buildLoadingPage();
          }
        });
  }

  Widget showCrosswords(List<CrosswordInfo> crosswordsInfoToShow) {
    if (crosswordsInfoToShow.isEmpty) {
      return const Center(
          child:
              Text('BRAK ZAPISANYCH KRZYŻÓWEK', textAlign: TextAlign.center));
    }
    crosswordsInfoToShow.sort((a, b) {
      int statusComp = -a.status.compareTo(b.status);
      if (statusComp == 0) {
        return a.crosswordName.compareTo(b.crosswordName);
      }
      return statusComp;
    });
    return ListView(padding: const EdgeInsets.all(5), children: <Widget>[
      for (var crosswordInfo in crosswordsInfoToShow)
        createCrosswordList(context, crosswordInfo),
    ]);
  }

  Future<List<CrosswordInfo>> getImages() async {
    CrosswordInfoRepository photoRepository = CrosswordInfoRepository();
    var userId = await PrefsUtil.getUserId();
    List<CrosswordInfo> photos =
        await photoRepository.getAllCrosswordsInfo(userId);
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
          displayRemoveCrosswordDialog(context, photo);
        },
        icon: const Icon(
          Icons.delete,
          size: 40.0,
          color: Colors.red,
        ),
      ),
    );
  }

  Future displayRemoveCrosswordDialog(
      BuildContext context, CrosswordInfo crosswordInfo) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 2.0),
              title: Transform.translate(
                offset: const Offset(0, -16),
                child: const Text('CZY NA PEWNO CHCESZ USUNĄĆ KRZYŻÓWKĘ?'),
              ),
              actions: createButtonsInRemoveClueDialog(context, crosswordInfo),
              actionsPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
            );
          });
        });
  }

  List<Widget> createButtonsInRemoveClueDialog(
      BuildContext context, CrosswordInfo crosswordInfo) {
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
            await HttpUtil.deleteCrossword(
                crosswordInfo.userId, crosswordInfo.id.toString());
            CrosswordInfoRepository photoRepository = CrosswordInfoRepository();
            await photoRepository.deleteCrosswordInfo(crosswordInfo.id);
            setState(() {
              crosswordsInfo.remove(crosswordInfo);
              Navigator.pop(context);
            });
          }),
    ];
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
                  child: Center(
                    heightFactor: MediaQuery.of(context).size.height,
                    widthFactor: 0.5,
                    child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1,
                        maxScale: 4,
                        child: widget.image),
                  ),
                ),
              ],
            )));
  }

  Future showEmptyNameAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 2.0),
              title: Transform.translate(
                offset: const Offset(0, -16),
                child:
                    const Text("NIE UDAŁO SIĘ ZAPISAĆ ZMIANY NAZWY KRZYŻÓWKI!"),
              ),
              content: const Text(
                  "NAZWA KRZYŻÓWKI NIE MOŻE BYĆ PUSTA LUB IDENTYCZNA Z JUŻ ISTNIEJĄCĄ."),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
              actionsPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
            );
          });
        });
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
