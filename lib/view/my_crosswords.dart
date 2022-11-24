import 'dart:async';
import 'dart:io';

import 'package:crossword_solver/util/loading_page_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../database/photoRepository.dart';
import '../model/photo.dart';

class MyCrosswords extends StatefulWidget {
  const MyCrosswords({super.key});

  @override
  State<MyCrosswords> createState() => MyCrosswordsState();
}

class MyCrosswordsState extends State<MyCrosswords> {
  late List<Photo> photos;

  @override
  void initState() {
    super.initState();
    getPhotos();
  }

  void refreshState() {
    getPhotos();
  }

  getPhotos() async {
    PhotoRepository photoRepository = PhotoRepository();
    photos = await photoRepository.getAllPhotos();
    setState(() {});
  }

  Future<List<Photo>> getImages() async {
    PhotoRepository photoRepository = PhotoRepository();
    List<Photo> photos = await photoRepository.getAllPhotos();
    return photos;
  }

  void removeImage(int id) async {
    PhotoRepository photoRepository = PhotoRepository();
    await photoRepository.deletePhoto(id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Photo>>(
        future: getImages(),
        builder: (context, images) {
          if (images.hasData) {
            return ListView(
                padding: const EdgeInsets.all(5),
                children: <Widget>[
                  for (var photo in images.data!)
                    createCrosswordList(context, photo),
                ]);
          } else {
            return LoadingPageUtil.buildLoadingPage();
          }
        });
  }

  Container createCrosswordList(BuildContext context, Photo photo) {
    Image image = Image.file(File(photo.path));

    return Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Expanded(flex: 25, child: SizedBox()),
          buildClickableImage(photo, image),
          const Expanded(flex: 25, child: SizedBox()),
          buildClickableCrosswordName(photo, image),
          const Expanded(flex: 25, child: SizedBox()),
          buildDateInProperFormat(photo.date),
          const Expanded(flex: 25, child: SizedBox()),
          buildRemoveButton(photo),
        ]));
  }

  Expanded buildClickableImage(Photo photo, Image image) {
    return Expanded(
        flex: 300,
        child: GestureDetector(
          child: image,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ModifyCrosswordNameScreen(photo, image);
            })).then((value) => {
                  if (value == true) {refreshState()}
                });
          },
        ));
  }

  Expanded buildClickableCrosswordName(Photo photo, Image image) {
    return Expanded(
        flex: 300,
        child: GestureDetector(
          child: Text(photo.name),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ModifyCrosswordNameScreen(photo, image);
            })).then((value) => {
                  if (value == true) {refreshState()}
                });
          },
        ));
  }

  Expanded buildDateInProperFormat(DateTime dateTime) {
    DateFormat format = DateFormat('yyyy-MM-dd\nhh:mm');
    return Expanded(flex: 300, child: Text(format.format(dateTime)));
  }

  Expanded buildRemoveButton(Photo photo) {
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

  void showDeletionAlert(BuildContext context, Photo photo) {
    Widget okButton = TextButton(
      child: const Text("Usuń"),
      onPressed: () {
        setState(() {
          photos.remove(photo);
        });
        removeImage(photo.id!);
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
}

class ModifyCrosswordNameScreen extends StatefulWidget {
  final Photo photo;
  final Image image;

  const ModifyCrosswordNameScreen(this.photo, this.image, {super.key});

  @override
  ModifyCrosswordNameScreenState createState() =>
      ModifyCrosswordNameScreenState();
}

class ModifyCrosswordNameScreenState extends State<ModifyCrosswordNameScreen> {
  final modifyCrosswordNameController = TextEditingController();

  @override
  initState() {
    super.initState();
    modifyCrosswordNameController.text = widget.photo.name;
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
                            widget.photo.name, newCrosswordName)) {
                          showEmptyNameAlert(context);
                        } else {
                          saveCrosswordName(widget.photo, newCrosswordName);
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

  void saveCrosswordName(Photo photo, String text) {
    PhotoRepository photoRepository = PhotoRepository();
    photo.name = text;
    photoRepository.updatePhoto(photo);
  }

  Future<bool> isCrosswordNameWrong(
      String oldCrosswordName, String newCrosswordName) async {
    PhotoRepository photoRepository = PhotoRepository();
    List<Photo> photos = await photoRepository.getAllPhotos();
    if (photos.map((photo) => photo.name).contains(newCrosswordName)) {
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
