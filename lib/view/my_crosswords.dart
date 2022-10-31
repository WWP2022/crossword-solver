import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:crossword_solver/util/path_util.dart';
import 'package:flutter/material.dart';

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
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
                padding: const EdgeInsets.all(8),
                children: <Widget>[
                  for (var img in snapshot.data!) createImage(img.path)
                ]);
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  bool isJpg(String path) {
    return path.endsWith(".jpg");
  }

  createImage(String string) {
    return Image(image: Image.file(File(string)).image);
  }

}
