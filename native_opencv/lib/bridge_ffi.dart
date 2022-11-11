import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

// C function signatures
typedef VersionFunction = Pointer<Utf8> Function();
typedef ImageProcessingFunction = Int32 Function(Pointer<Utf8>);

// Dart function signatures
typedef VersionFunctionDart = Pointer<Utf8> Function();
typedef ImageProcessingFunctionDart = int Function(Pointer<Utf8>);

class FFIBridge {
  late VersionFunctionDart _getVersion;
  late ImageProcessingFunctionDart _imageProcessing;

  FFIBridge() {
    final DynamicLibrary dl = Platform.isAndroid
        ? DynamicLibrary.open('libnative_opencv.so')
        : DynamicLibrary.process();

    _getVersion =
        dl.lookupFunction<VersionFunction, VersionFunctionDart>('get_version');

    _imageProcessing =
        dl.lookupFunction<ImageProcessingFunction, ImageProcessingFunctionDart>('image_processing');
  }

  String getVersion() => _getVersion().toDartString();

  int imageProcessing(String path) => _imageProcessing(path.toNativeUtf8());
}
