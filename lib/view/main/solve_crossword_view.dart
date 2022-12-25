import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:crossword_solver/database/crossword_info_repository.dart';
import 'package:crossword_solver/model/crossword_info.dart';
import 'package:crossword_solver/util/http_util.dart';
import 'package:crossword_solver/util/prefs_util.dart';
import 'package:crossword_solver/view/save_crossword_view.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../util/loading_page_util.dart';
import '../../util/modify_image_util.dart';
import '../../util/path_util.dart';

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
  late CameraController cameraController;
  late Future<void> _initializeControllerFuture;
  late FlashMode flashMode;

  @override
  void initState() {
    super.initState();
    flashMode = FlashMode.off;
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.medium);
    _initializeControllerFuture = cameraController.initialize();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        children: <Widget>[
          galleryFloatingButton(context),
          photoFloatingButton(context),
          flashFloatingButton(context),
        ],
      ),
    );
  }

  Transform buildFullScreenCamera(BuildContext context) {
    double controllerAspectRatio = cameraController.value.aspectRatio;
    double contextAspectRatio = MediaQuery.of(context).size.aspectRatio;
    final scale = 1 / (controllerAspectRatio * contextAspectRatio);
    return Transform.scale(
      scale: scale,
      alignment: Alignment.topCenter,
      child: CameraPreview(cameraController),
    );
  }

  Expanded galleryFloatingButton(BuildContext context) {
    return Expanded(
      flex: 10,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
            child: const Icon(Icons.photo),
            onPressed: () async {
              await choosePhotoAndSolve(context);
            }),
      ),
    );
  }

  Expanded photoFloatingButton(BuildContext context) {
    return Expanded(
      flex: 10,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          child: const Icon(Icons.camera_alt),
          onPressed: () async {
            await takePhotoAndSolve(context);
          },
        ),
      ),
    );
  }

  Expanded flashFloatingButton(BuildContext context) {
    return Expanded(
      flex: 10,
      child: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          child: showFlashIcon(),
          onPressed: () {
            changeFlashMode();
          },
        ),
      ),
    );
  }

  Icon showFlashIcon() {
    if (flashMode == FlashMode.off) {
      return const Icon(Icons.flash_off);
    }
    return const Icon(Icons.flash_on);
  }

  void changeFlashMode() {
    setState(() {
      if (flashMode == FlashMode.off) {
        flashMode = FlashMode.always;
      } else {
        flashMode = FlashMode.off;
      }
    });
  }

  Future<void> choosePhotoAndSolve(BuildContext context) async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      XFile imageFromGallery = XFile(pickedFile.path);

      String croppedImagePath = await cropImage(imageFromGallery);

      await solve(context, croppedImagePath);
    }
  }

  Future<void> takePhotoAndSolve(BuildContext context) async {
    try {
      await _initializeControllerFuture;
      cameraController.setFlashMode(flashMode);
      XFile imageFromCamera = await cameraController.takePicture();

      if (!mounted) {
        return;
      }

      String croppedImagePath = await cropImage(imageFromCamera);

      await solve(context, croppedImagePath);
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

  Future<void> solve(BuildContext context, String croppedImagePath) async {
    String userId = await PrefsUtil.getUserId();

    var responseAfterUpload =
        await uploadAndSaveUnprocessedImage(userId, croppedImagePath, context);

    var crosswordId = responseAfterUpload['id'];
    var crosswordName = responseAfterUpload['crossword_name'];
    print(crosswordId);
    print(crosswordName);

    var responseAfterStatusCheck =
        await checkCrosswordStatus(userId, crosswordId.toString(), context);

    var status = responseAfterStatusCheck['status'];

    if (status == "cannot_solve") {
      print("cant solve crossword");

      var snackBar = serverSolvingErrorSnackBar(responseAfterStatusCheck);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print("crossword solved - waiting");

      var getSolvedCrosswordResponse =
          await HttpUtil.getSolvedCrossword(userId, crosswordId.toString());

      Directory documentDirectory = await getApplicationDocumentsDirectory();
      File solvedImageFile =
          File(join(documentDirectory.path, '$crosswordName.png'));
      solvedImageFile.writeAsBytesSync(getSolvedCrosswordResponse.bodyBytes);

      print(solvedImageFile);
      print(solvedImageFile.path);

      saveImageBeforeAccept(
          crosswordId, solvedImageFile.path, crosswordName, userId, status);

      var snackBar = serverSolvedMessageSnackbar(
          context,
          responseAfterStatusCheck,
          solvedImageFile.path,
          crosswordId.toString(),
          crosswordName);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<dynamic> uploadAndSaveUnprocessedImage(
      String userId, String imagePath, BuildContext context) async {
    var response = await sendImageToServer(userId, imagePath, context);

    var crosswordId = response['id'];
    var crosswordName = response['crossword_name'];

    saveUnprocessedImageInDatabase(
        crosswordId, imagePath, crosswordName, userId);

    return response;
  }

  Future<dynamic> sendImageToServer(
      String userId, String imagePath, BuildContext context) async {
    var response = await HttpUtil.sendCrossword(userId, imagePath);

    var body = jsonDecode(response.body);

    var status = response.statusCode;
    if (status == 200) {
      print('upload sucess');
    } else {
      print("Error ${response.statusCode}");
    }

    return body;
  }

  void saveUnprocessedImageInDatabase(
      int id, String path, String crosswordName, String userId) async {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    CrosswordInfo crosswordInfo = CrosswordInfo(
        id: id,
        path: path,
        crosswordName: crosswordName,
        timestamp: DateTime.now(),
        userId: userId,
        status: "new");
    crosswordInfoRepository.insertCrosswordInfo(crosswordInfo);
  }

  Future<dynamic> checkCrosswordStatus(
      String userId, String crosswordId, BuildContext context) async {
    print("checkCrosswordStatus");

    dynamic decodedResponse;
    String status;

    do {
      await Future.delayed(const Duration(seconds: 1));

      var resposne =
          await HttpUtil.getCrosswordStatus(userId, crosswordId.toString());

      decodedResponse = jsonDecode(resposne.body);
      print(decodedResponse);

      status = decodedResponse['status'];
      print(status);
    } while (status != "solved_waiting" && status != "cannot_solve");

    if (status == "cannot_solve") {
      print("cant solve crossword");
    } else {
      print("crossword solved - waiting");
    }

    return decodedResponse;
  }

  SnackBar serverSolvedMessageSnackbar(
      context, dynamic decodedResponse, String path, String id, String name) {
    var status = decodedResponse['status'];
    var message = decodedResponse['message'];

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      content: const Text("Pomyślnie rozwiązano krzyżówkę",
          style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: (Colors.green),
      action: SnackBarAction(
        textColor: Colors.indigo,
        label: 'Pokaż',
        onPressed: () {
          navigateToSaveCrossword(context, path, id, name);
        },
      ),
    );
  }

  SnackBar serverSolvingErrorSnackBar(dynamic decodedResponse) {
    var message = decodedResponse['message'];

    var errorMessageMap = {
      "lines_not_found": "nie znaleziono linii",
      "crossword_not_found": "nie znaleziono krzyżówki",
      "cannot_cropped_images": "nie można podzielić krzyżówki"
    };

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
          "Nie udało się rozwiązać krzyżówki: ${errorMessageMap[message]}"),
      backgroundColor: (Colors.red),
      // action: SnackBarAction(
      //   label: 'dismiss',
      //   onPressed: () {
      //   },
      // ),
    );
  }

  void navigateToSaveCrossword(context, String path, String id, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SaveCrossword(path: path, id: id, name: name)),
    );
  }

  void saveImageBeforeAccept(int id, String path, String crosswordName,
      String userId, String status) async {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    CrosswordInfo crosswordInfo = CrosswordInfo(
        id: id,
        path: path,
        crosswordName: crosswordName,
        timestamp: DateTime.now(),
        userId: userId,
        status: status);
    await crosswordInfoRepository.insertCrosswordInfo(crosswordInfo);
  }

  SnackBar serverErrorSnackBar(String statusCode) {
    return SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text("Server error! Status code: $statusCode"));
  }
}
