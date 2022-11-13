import 'dart:async';
import 'dart:io';

import 'package:crossword_solver/util/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  bool isJpg(String path) {
    return path.endsWith(".jpg");
  }

  createCrosswordList(BuildContext context, Photo photo) {
    Image image = Image.file(File(photo.path));
    String date = photo.date.toIso8601String();
    String crosswordName = photo.name;

    return Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Expanded(flex: 25, child: SizedBox()),
          Expanded(
              flex: 300,
              child: GestureDetector(
                child: image,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return DetailScreen(image);
                  }));
                },
              )),
          const Expanded(flex: 25, child: SizedBox()),
          Expanded(flex: 300, child: Text(crosswordName)),
          const Expanded(flex: 25, child: SizedBox()),
          Expanded(flex: 300, child: Text(date)),
          const Expanded(flex: 25, child: SizedBox()),
          Expanded(
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
          ),
        ]));
  }
}

class DetailScreen extends StatefulWidget {
  Image image;

  DetailScreen(this.image, {super.key});

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
