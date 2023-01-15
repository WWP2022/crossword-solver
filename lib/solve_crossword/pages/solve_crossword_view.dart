import 'package:crossword_solver/solve_crossword/services/solve_crossword_service.dart';
import 'package:crossword_solver/solve_crossword/widgets/custom_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class SolveCrossword extends ConsumerStatefulWidget {
  const SolveCrossword({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<SolveCrossword> {
  final SolveCrosswordService solveCrosswordService = SolveCrosswordService();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/crossword_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: CustomFloatingButton(
                  icon: Icons.photo,
                  onPressed: () async {
                    await solveCrosswordService.serveGalleryButton(
                        context, ref);
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: CustomFloatingButton(
                    icon: Icons.camera,
                    onPressed: () async {
                      if (await isCameraPermitted()) {
                        solveCrosswordService.serveCameraButton(context, ref);
                      }
                    }),
              ),
            ],
          ),
        ));
  }

  Future<bool> isCameraPermitted() async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }
    if (!isCameraGranted) {
      return false;
    }
    return true;
  }
}
