import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

List<CameraDescription>? _availableCameras;

/// Call this once in main() before runApp
Future<void> initializeCameras() async {
  _availableCameras = await availableCameras();
}

List<CameraDescription> getAvailableCameras() {
  if (_availableCameras == null) {
    throw Exception("Cameras not initialized. Call initializeCameras() first.");
  }
  return _availableCameras!;
}

/// Initializes the selected camera (front or back)
Future<CameraController> initializeCamera(CameraDescription camera) async {
  final controller = CameraController(camera, ResolutionPreset.medium);
  await controller.initialize();
  return controller;
}

/// Captures a square-cropped photo using the provided controller
Future<File> takeAndCropPhoto(CameraController controller) async {
  final image = await controller.takePicture();

  final bytes = await File(image.path).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception("Failed to decode image");

  final fixedImage = img.bakeOrientation(decoded);

  final size = fixedImage.width < fixedImage.height
      ? fixedImage.width
      : fixedImage.height;

  final offsetX = (fixedImage.width - size) ~/ 2;
  final offsetY = (fixedImage.height - size) ~/ 2;

  final cropped = img.copyCrop(
    fixedImage,
    x: offsetX,
    y: offsetY,
    width: size,
    height: size,
  );

  final directory = await getApplicationDocumentsDirectory();
  final path =
      '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_square.jpg';

  return File(path)..writeAsBytesSync(img.encodeJpg(cropped));
}
