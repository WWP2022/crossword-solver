import 'dart:async';
import 'dart:io';

import 'package:crossword_solver/util/loading_page.dart';
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
            return LoadingPage.buildLoadingPage();
          }
        });
  }

  Container createCrosswordList(BuildContext context, Photo photo) {
    Image image = Image.file(File(photo.path));

    return Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Expanded(flex: 25, child: SizedBox()),
          buildClickableImage(image),
          const Expanded(flex: 25, child: SizedBox()),
          buildClickableCrosswordName(photo, image),
          const Expanded(flex: 25, child: SizedBox()),
          buildDateInProperFormat(photo.date),
          const Expanded(flex: 25, child: SizedBox()),
          buildRemoveButton(photo),
        ]));
  }

  Expanded buildClickableImage(Image image) {
    return Expanded(
        flex: 300,
        child: GestureDetector(
          child: image,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return DetailScreen(image);
            }));
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
          setState(() {
            photos.remove(photo);
          });
          // removing crossword also from database
          removeImage(photo.id!);
        },
        icon: const Icon(
          Icons.delete,
          size: 40.0,
          color: Colors.red,
        ),
      ),
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
                Center(widthFactor: 0.5, child: widget.image),
                SizedBox(
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      alignLabelWithHint: true,
                    ),
                    controller: modifyCrosswordNameController,
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  onPressed: () {
                    String newCrosswordName =
                        modifyCrosswordNameController.text;
                    if (isCrosswordNameWrong(
                        widget.photo.name, newCrosswordName)) {
                      showEmptyNameAlert(context);
                    } else {
                      saveCrosswordName(widget.photo, newCrosswordName);
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Zmodyfikuj nazwę krzyżówki'),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  onPressed: () => {
                    Navigator.pop(context, false),
                  },
                  child: const Text('Anuluj'),
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
          "Nazwa krzyżówki nie może być pusta lub identyczna z poprzednią."),
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

  bool isCrosswordNameWrong(String oldCrosswordName, String newCrosswordName) {
    if (oldCrosswordName == newCrosswordName) return true;
    if (newCrosswordName.isEmpty) return true;
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
