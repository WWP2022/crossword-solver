import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:crossword_solver/util/path_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyCrosswords extends StatelessWidget {
  const MyCrosswords({super.key});

  Future<List<FileSystemEntity>> getImages() async {
    String localPath = await PathUtil.localPath;
    List<FileSystemEntity> imagesList = io.Directory("$localPath/")
        .listSync()
        .where((element) => isJpg(element.path))
        .toList();

    return imagesList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
        future: getImages(),
        builder: (context, images) {
          if (images.hasData) {
            return ListView(
                padding: const EdgeInsets.all(5),
                children: <Widget>[
                  for (var img in images.data!)
                    createCrosswordList(context, img.path),
                ]);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  bool isJpg(String path) {
    return path.endsWith(".jpg");
  }

  createCrosswordList(BuildContext context, String path) {
    final image = Image.file(File(path));
    final date = DateTime.now().toString();

    return Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
            const Expanded(flex: 300, child: Text('Krzyżówka X')),
            const Expanded(flex: 25, child: SizedBox()),
            Expanded(flex: 300, child: Text(date)),
            const Expanded(flex: 25, child: SizedBox()),
          ],
        ));
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
