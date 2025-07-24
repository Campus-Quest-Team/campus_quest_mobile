import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Initializes the back-facing camera
Future<CameraController> initializeCamera() async {
  final cameras = await availableCameras();
  final backCamera = cameras.first;

  final controller = CameraController(backCamera, ResolutionPreset.medium);
  await controller.initialize();
  return controller;
}

/// Captures a square-cropped photo using the provided controller
Future<File> takeAndCropPhoto(CameraController controller) async {
  final image = await controller.takePicture();

  final bytes = await File(image.path).readAsBytes();
  final decodedImage = img.decodeImage(bytes);

  if (decodedImage == null) throw Exception("Failed to decode image");

  final size = decodedImage.width < decodedImage.height
      ? decodedImage.width
      : decodedImage.height;

  final offsetX = (decodedImage.width - size) ~/ 2;
  final offsetY = (decodedImage.height - size) ~/ 2;

  final cropped = img.copyCrop(
    decodedImage,
    x: offsetX,
    y: offsetY,
    width: size,
    height: size,
  );

  final directory = await getApplicationDocumentsDirectory();
  final path =
      '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_square.jpg';
  final savedImage = File(path)..writeAsBytesSync(img.encodeJpg(cropped));

  return savedImage;
}
