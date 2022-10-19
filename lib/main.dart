import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'view/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<CameraDescription> cameras = await availableCameras();
  final CameraDescription camera = cameras.first;
  runApp(App(camera));
}
