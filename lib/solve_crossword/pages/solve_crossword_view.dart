import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:crossword_solver/auth/controllers/providers.dart';
import 'package:crossword_solver/core/utils/http_util.dart';
import 'package:crossword_solver/core/utils/loading_page_util.dart';
import 'package:crossword_solver/core/utils/modify_image_util.dart';
import 'package:crossword_solver/core/utils/path_util.dart';
import 'package:crossword_solver/core/utils/prefs_util.dart';
import 'package:crossword_solver/database/crossword_info_repository.dart';
import 'package:crossword_solver/model/crossword_info.dart';
import 'package:crossword_solver/save_crossword_view.dart';
import 'package:crossword_solver/solve_crossword/widgets/custom_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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

class TakePictureScreen extends ConsumerStatefulWidget {
  const TakePictureScreen({super.key});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends ConsumerState<TakePictureScreen> {
  late CameraController cameraController;
  late Future<void> _initializeControllerFuture;
  late FlashMode flashMode;

  @override
  void initState() {
    super.initState();
    flashMode = FlashMode.off;
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.max);
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
            return SizedBox(
              width: double.infinity,
              child: CameraPreview(cameraController),
            );
          } else {
            return LoadingPageUtil.buildLoadingPage();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CustomFloatingButton(
              icon: Icons.photo,
              onPressed: () async {
                await choosePhotoAndSolve(context, ref);
              },
            ),
            CustomFloatingButton(
              icon: Icons.camera_alt,
              onPressed: () async {
                await takePhotoAndSolve(context, ref);
              },
            ),
            CustomFloatingButton(
              icon: (flashMode == FlashMode.always)
                  ? Icons.flash_on
                  : Icons.flash_off,
              onPressed: () {
                setState(() {
                  if (flashMode == FlashMode.off) {
                    flashMode = FlashMode.always;
                  } else {
                    flashMode = FlashMode.off;
                  }
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> choosePhotoAndSolve(
    BuildContext context,
    WidgetRef ref,
  ) async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      XFile imageFromGallery = XFile(pickedFile.path);

      String croppedImagePath = await cropImage(imageFromGallery);

      await solve(context, croppedImagePath, ref);
    }
  }

  Future<void> takePhotoAndSolve(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await _initializeControllerFuture;
      cameraController.setFlashMode(flashMode);
      XFile imageFromCamera = await cameraController.takePicture();

      if (!mounted) {
        return;
      }

      String croppedImagePath = await cropImage(imageFromCamera);

      await solve(context, croppedImagePath, ref);
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

  Future<void> solve(
    BuildContext context,
    String croppedImagePath,
    WidgetRef ref,
  ) async {
    String userId = await PrefsUtil.getUserId();

    var responseAfterUpload = await uploadAndSaveUnprocessedImage(
      userId,
      croppedImagePath,
      context,
      ref,
    );

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
        crosswordName,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<dynamic> uploadAndSaveUnprocessedImage(
    String userId,
    String imagePath,
    BuildContext context,
    WidgetRef ref,
  ) async {
    var response = await sendImageToServer(userId, imagePath, context, ref);

    var crosswordId = response['id'];
    var crosswordName = response['crossword_name'];

    saveUnprocessedImageInDatabase(
        crosswordId, imagePath, crosswordName, userId);

    return response;
  }

  Future<dynamic> sendImageToServer(
    String userId,
    String imagePath,
    BuildContext context,
    WidgetRef ref,
  ) async {
    var response = await HttpUtil.sendCrossword(userId, imagePath);

    var body = jsonDecode(response.body);

    var status = response.statusCode;
    if (status == 200) {
      print('upload sucess');
      ref.read(manageUserNotifierProvider.notifier).incrementSentCrosswords();
    } else {
      print("Error ${response.statusCode}");
    }

    return body;
  }

  void saveUnprocessedImageInDatabase(
    int id,
    String path,
    String crosswordName,
    String userId,
  ) async {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    CrosswordInfo crosswordInfo = CrosswordInfo(
      id: id,
      path: path,
      crosswordName: crosswordName,
      timestamp: DateTime.now(),
      userId: userId,
      status: "new",
    );
    crosswordInfoRepository.insertCrosswordInfo(crosswordInfo);
  }

  Future<dynamic> checkCrosswordStatus(
    String userId,
    String crosswordId,
    BuildContext context,
  ) async {
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
    context,
    dynamic decodedResponse,
    String path,
    String id,
    String name,
  ) {
    var status = decodedResponse['status'];
    var message = decodedResponse['message'];

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      content: const Text(
        "Pomy??lnie rozwi??zano krzy????wk??",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: (Colors.green),
      action: SnackBarAction(
        textColor: Colors.indigo,
        label: 'Poka??',
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
      "crossword_not_found": "nie znaleziono krzy????wki",
      "cannot_cropped_images": "nie mo??na podzieli?? krzy????wki"
    };

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        "Nie uda??o si?? rozwi??za?? krzy????wki: ${errorMessageMap[message]}",
      ),
      backgroundColor: (Colors.red),
      // action: SnackBarAction(
      //   label: 'dismiss',
      //   onPressed: () {
      //   },
      // ),
    );
  }

  void navigateToSaveCrossword(
    context,
    String path,
    String id,
    String name,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaveCrossword(
          path: path,
          id: id,
          name: name,
        ),
      ),
    );
  }

  void saveImageBeforeAccept(
    int id,
    String path,
    String crosswordName,
    String userId,
    String status,
  ) async {
    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();
    CrosswordInfo crosswordInfo = CrosswordInfo(
      id: id,
      path: path,
      crosswordName: crosswordName,
      timestamp: DateTime.now(),
      userId: userId,
      status: status,
    );
    await crosswordInfoRepository.insertCrosswordInfo(crosswordInfo);
  }

  SnackBar serverErrorSnackBar(String statusCode) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      content: Text(
        "Server error! Status code: $statusCode",
      ),
    );
  }
}
