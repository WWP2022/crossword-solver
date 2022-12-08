import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:crossword_solver/database/crossword_info_repository.dart';
import 'package:crossword_solver/model/crossword_info.dart';
import 'package:crossword_solver/util/http_util.dart';
import 'package:crossword_solver/util/prefs_util.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../util/loading_page_util.dart';
import '../util/modify_image_util.dart';
import '../util/path_util.dart';
import 'app.dart';


late CameraDescription cameraDescription;

class SolveCrossword extends StatelessWidget {
  const SolveCrossword({super.key});

  Future<bool> isCameraSet() async {
    WidgetsFlutterBinding.ensureInitialized();
    List<CameraDescription> cameras = await availableCameras();
    cameraDescription = cameras.first;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isCameraSet(),
        builder: (context, camera) {
          if (camera.hasData) {
            return const TakePictureScreen();
          } else {
            return LoadingPageUtil.buildLoadingPage();
          }
        });
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Transform buildFullScreenCamera(BuildContext context) {
    double controllerAspectRatio = _controller.value.aspectRatio;
    double contextAspectRatio = MediaQuery.of(context).size.aspectRatio;
    final scale = 1 / (controllerAspectRatio * contextAspectRatio);
    return Transform.scale(
      scale: scale,
      alignment: Alignment.topCenter,
      child: CameraPreview(_controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return buildFullScreenCamera(context);
          } else {
            return LoadingPageUtil.buildLoadingPage();
          }
        },
      ),
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(flex: 3, child: SizedBox()),
          Expanded(
            flex: 10,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                  child: const Icon(Icons.photo),
                  onPressed: () async {
                    await choosePhoto(context);
                  }),
            ),
          ),
          Expanded(
            flex: 10,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                child: const Icon(Icons.camera_alt),
                onPressed: () async {
                  await takePhoto(context);
                },
              ),
            ),
          ),
          const Expanded(flex: 10, child: SizedBox()),
        ],
      ),
    );
  }

  Future<void> choosePhoto(BuildContext context) async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      XFile imageFromGallery = XFile(pickedFile.path);

      String croppedImagePath = await cropImage(imageFromGallery);
      await uploadAndSaveUnprocessedImage(croppedImagePath);

      navigateToApp(context);
    }
  }

  Future<void> takePhoto(BuildContext context) async {
    try {
      await _initializeControllerFuture;
      XFile imageFromCamera = await _controller.takePicture();

      if (!mounted) {
        return;
      }

      String croppedImagePath = await cropImage(imageFromCamera);
      await uploadAndSaveUnprocessedImage(croppedImagePath);

      navigateToApp(context);
    } catch (e) {
      print(e);
    }
  }

  Future<String> cropImage(XFile image) async {
    String duplicateFilePath = await PathUtil.localPath;
    String fileName = basename(image.name);
    final path = '$duplicateFilePath/$fileName';
    await image.saveTo(path);

    File savedImage = File(path);
    File compressedImage = await ModifyImageUtil.compress(image: savedImage);
    CroppedFile? croppedImage =
        await ModifyImageUtil.cropImage(compressedImage);

    XFile processedImage = XFile.fromData(await croppedImage!.readAsBytes());
    await processedImage.saveTo(path);

    return path;
  }

  Future<void> uploadAndSaveUnprocessedImage(String imagePath) async {
    String userId = await PrefsUtil.getUserId();

    var response = await sendImageToServer(userId, imagePath);

    var crosswordId = response['id'];
    var crosswordName = response['crossword_name'];

    saveUnprocessedImageInDatabase(
        crosswordId,
        imagePath,
        crosswordName,
        userId
    );
  }

  Future<dynamic> sendImageToServer(String userId, String imagePath) async {
    var response = await HttpUtil.crosswordSend(
        userId,
        File(imagePath)
    );

    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print('upload sucess');

      // TODO
      // alert ze krzyzowka wyslana na serwer albo ze sie nie udalo
      // utworzenie watku do sprawdzania statusu
      // TODO

    } else {
      print("Error ${response.statusCode}");
    }

    return body;
  }

  void saveUnprocessedImageInDatabase(int id, String path, String crosswordName, String userId) async {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    CrosswordInfo crosswordInfo = CrosswordInfo(
        id: id,
        path: path,
        crosswordName: crosswordName,
        timestamp: DateTime.now(),
        userId: userId,
        status: "new"
    );
    crosswordInfoRepository.insertCrosswordInfo(crosswordInfo);
  }

  void navigateToApp(context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const App(),
    ));
  }
}
