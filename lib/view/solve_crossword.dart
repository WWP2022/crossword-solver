import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:crossword_solver/database/crossword_info_repository.dart';
import 'package:crossword_solver/model/crossword_info.dart';
import 'package:crossword_solver/util/http_util.dart';
import 'package:crossword_solver/util/prefs_util.dart';
import 'package:crossword_solver/view/save_crossword.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
      String userId = await PrefsUtil.getUserId();

      await uploadAndSaveUnprocessedImage(userId, croppedImagePath, context);

      // navigateToApp(context);
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
      String userId = await PrefsUtil.getUserId();

      var responseAfterUpload = await uploadAndSaveUnprocessedImage(userId, croppedImagePath, context);

      var crosswordId = responseAfterUpload['id'];
      var crosswordName = responseAfterUpload['crossword_name'];
      print(crosswordId);
      print(crosswordName);

      var responseAfterStatusCheck = await checkCrosswordStatus(userId, crosswordId.toString(), context);

      var status = responseAfterStatusCheck['status'];

      if (status == "cannot_solve") {
        print("cant solve crossword");
        var snackBar = serverSolvingErrorSnackBar(responseAfterStatusCheck);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        print("crossword solved - waiting");
        var getSolvedCrosswordResponse = await HttpUtil.getSolvedCrossword(
            userId,
            crosswordId.toString()
        );

        Directory documentDirectory = await getApplicationDocumentsDirectory();
        File solvedImageFile = File(join(documentDirectory.path, '$crosswordName.png'));
        solvedImageFile.writeAsBytesSync(getSolvedCrosswordResponse.bodyBytes);

        print(solvedImageFile);
        print(solvedImageFile.path);

        // navigateToSaveCrossword(context, solvedImageFile.path);

        var snackBar = serverSolvedMessageSnackbar(
          context,
          responseAfterStatusCheck,
          solvedImageFile.path,
          crosswordId.toString(),
          crosswordName
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        //navigateToApp(context);
      }
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

  Future<dynamic> uploadAndSaveUnprocessedImage(String userId, String imagePath, BuildContext context) async {
    var response = await sendImageToServer(userId, imagePath, context);

    var crosswordId = response['id'];
    var crosswordName = response['crossword_name'];

    saveUnprocessedImageInDatabase(
        crosswordId, imagePath, crosswordName, userId);

    return response;
  }

  Future<dynamic> sendImageToServer(String userId, String imagePath, BuildContext context) async {
    var response = await HttpUtil.sendCrossword(userId, imagePath
    );

    var body = jsonDecode(response.body);

    var status = response.statusCode;
    if (status == 200) {
      print('upload sucess');

      // ScaffoldMessenger.of(context)
      //     .showSnackBar(serverErrorSnackBar(status.toString()));

      // TODO
      // alert ze krzyzowka wyslana na serwer albo ze sie nie udalo
      // utworzenie watku do sprawdzania statusu
      // TODO

    } else {
      print("Error ${response.statusCode}");

      // ScaffoldMessenger.of(context)
      //     .showSnackBar(serverErrorSnackBar(status.toString()));
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

  void navigateToApp(context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const App(),
    ));
  }

  SnackBar serverErrorSnackBar(String statusCode) {
    return SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text("Error! Status code: $statusCode")
    );
  }

  Future<dynamic> checkCrosswordStatus(String userId, String crosswordId, BuildContext context) async {
    print("checkCrosswordStatus");

    var resposne = await HttpUtil.getCrosswordStatus(
        userId,
        crosswordId.toString()
    );

    var decodedResponse = jsonDecode(resposne.body);
    print(decodedResponse);

    var status = decodedResponse['status'];
    print(status);

    while (status != "solved_waiting" && status != "cannot_solve") {
      await Future.delayed(const Duration(seconds: 1));

      var resposne = await HttpUtil.getCrosswordStatus(
          userId,
          crosswordId.toString()
      );

      decodedResponse = jsonDecode(resposne.body);
      print(decodedResponse);

      status = decodedResponse['status'];
      print(status);
    }

    if (status == "cannot_solve") {
      print("cant solve crossword");
    } else {
      print("crossword solved - waiting");
    }

    return decodedResponse;
  }

  SnackBar serverSolvedMessageSnackbar(context, dynamic decodedResponse, String path, String id, String name) {
    var status = decodedResponse['status'];
    var message = decodedResponse['message'];

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text("Status: $status, message: $message"),
      backgroundColor: (Colors.green),
      action: SnackBarAction(
        label: 'Go to crossword',
        onPressed: () {
          navigateToSaveCrossword(context, path, id, name);
        },
      ),
    );
  }

  SnackBar serverSolvingErrorSnackBar(dynamic decodedResponse) {
    var status = decodedResponse['status'];
    var message = decodedResponse['message'];

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text("Status: $status, message: $message"),
      backgroundColor: (Colors.red),
      action: SnackBarAction(
        label: 'dismiss',
        onPressed: () {
        },
      ),
    );
  }

  void navigateToSaveCrossword(context, String path, String id, String name) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SaveCrossword(path: path, id: id, name: name)),
          (Route<dynamic> route) => false,
    );
  }
}
