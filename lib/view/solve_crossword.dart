import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:crossword_solver/view/save_crossword.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';

import '../util/modify_image_util.dart';
import '../util/loading_page_util.dart';
import '../util/path_util.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            XFile image = await _controller.takePicture();

            // TODO this is only for tests cpp code
            // String duplicateFilePath = await PathUtil.localPath;
            // String fileName = basename(image.name);
            // String path = '$duplicateFilePath/$fileName';
            // FFIBridge _ffiBridge = FFIBridge();
            // print(_ffiBridge.imageProcessing(path));
            //TODO this is only for tests cpp code

            if (!mounted) {
              return;
            }
            String path = await cropImage(image);
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) =>
                      SaveCrossword(path: path, imageName: image.name)),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Future<String> cropImage(XFile image) async {
    String duplicateFilePath = await PathUtil.localPath;
    String fileName = basename(image.name);
    final path = '$duplicateFilePath/$fileName';
    await image.saveTo('$duplicateFilePath/$fileName');

    File savedImage = File(path);
    File compressedImage = await ModifyImageUtil.compress(image: savedImage);
    CroppedFile? croppedImage = await ModifyImageUtil.cropImage(compressedImage);

    XFile processedImage = XFile.fromData(await croppedImage!.readAsBytes());
    await processedImage.saveTo(path);
    return path;
  }
}
