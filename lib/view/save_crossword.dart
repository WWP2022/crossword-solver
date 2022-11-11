import 'dart:io';

import 'package:camera/camera.dart';
import 'package:crossword_solver/database/photoRepository.dart';
import 'package:crossword_solver/util/path_util.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../util/crop_compress_image.dart';
import '../model/photo.dart';

class SaveCrossword extends StatefulWidget {
  final XFile image;

  const SaveCrossword(this.image, {Key? key}) : super(key: key);

  @override
  State<SaveCrossword> createState() => _SaveCrossword();
}

class _SaveCrossword extends State<SaveCrossword> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
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
          child: Image.file(File(widget.image.path)),
        ),
        TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () {
            saveAndDropImage(widget.image, myController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Zapisz zdjęcie'),
        )
      ],
    );
  }

  saveAndDropImage(XFile image, String photoName) async {
    String duplicateFilePath = await PathUtil.localPath;
    String fileName = basename(image.name);

    final path = '$duplicateFilePath/$fileName';
    await image.saveTo('$duplicateFilePath/$fileName');

    File savedImage = File('$duplicateFilePath/$fileName');
    var compressedImage = await AppHelper.compress(image: savedImage);
    var croppedImage = await AppHelper.cropImage(compressedImage);

    XFile processedImage = XFile.fromData(await croppedImage!.readAsBytes());
    await processedImage.saveTo('$duplicateFilePath/$fileName');

    PhotoRepository photoRepository = PhotoRepository();
    Photo photo = Photo(path: path, name: photoName, date: DateTime.now());
    photoRepository.insertPhoto(photo);
  }
}
