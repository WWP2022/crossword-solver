import 'dart:ffi';
import 'dart:io';

typedef NumberFunction = Int Function();
typedef NumberFunctionDart = int Function();

class FFIBridge {
  late NumberFunctionDart _getNumber;

  FFIBridge() {
    final dl = Platform.isAndroid
        ? DynamicLibrary.open('libimage_processing.so')
        : DynamicLibrary.process();

    _getNumber =
        dl.lookupFunction<NumberFunction, NumberFunctionDart>('get_number');
  }

  int getNumber() => _getNumber();
}
