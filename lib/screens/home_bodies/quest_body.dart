import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class QuestBody extends StatefulWidget {
  final VoidCallback onBackToFeedTap;

  const QuestBody({super.key, required this.onBackToFeedTap});

  @override
  State<QuestBody> createState() => _QuestBodyState();
}

class _QuestBodyState extends State<QuestBody> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false;
  bool _photoCaptured = false;
  File? _savedImage;
  final TextEditingController _captionController = TextEditingController();

  final String questDescription =
      'Locate the legendary compass hidden in the old forest.';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.first;

    _cameraController = CameraController(backCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _cameraController.initialize();
    await _initializeControllerFuture;

    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();

      // Load image bytes
      final bytes = await File(image.path).readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) throw Exception("Failed to decode image");

      // Crop to square (centered)
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

      // Save cropped image
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_square.jpg';
      final savedImage = File(path)..writeAsBytesSync(img.encodeJpg(cropped));

      setState(() {
        _savedImage = savedImage;
        _photoCaptured = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  void _submitQuest() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Quest submitted!')));
  }

  void _retakePhoto() {
    setState(() {
      _photoCaptured = false;
      _savedImage = null;
      _captionController.clear();
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToFeedTap,
        ),
        title: const Text('Your Quest'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                questDescription,
                style: TextStyle(fontSize: 25.sp, color: Colors.grey[800]),
              ),
            ),
            SizedBox(height: 12.h),
            _isCameraInitialized
                ? GestureDetector(
                    onDoubleTap: _takePhoto,
                    child: Stack(
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _photoCaptured && _savedImage != null
                                  ? Image.file(_savedImage!, fit: BoxFit.cover)
                                  : OverflowBox(
                                      alignment: Alignment.center,
                                      maxWidth: double.infinity,
                                      maxHeight: double.infinity,
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: _cameraController
                                              .value
                                              .previewSize!
                                              .height,
                                          height: _cameraController
                                              .value
                                              .previewSize!
                                              .width,
                                          child: CameraPreview(
                                            _cameraController,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        if (_photoCaptured)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: IconButton(
                              onPressed: _retakePhoto,
                              icon: const Icon(Icons.refresh),
                              color: Colors.white,
                              iconSize: 30,
                              tooltip: 'Retake Photo',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
            SizedBox(height: 12.h),
            Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Enter Quest Notes'),
                      content: TextField(
                        controller: _captionController,
                        decoration: const InputDecoration(
                          labelText: 'Your thoughts...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: 'Quest notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ),
            if (_photoCaptured)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: ElevatedButton(
                    onPressed: _submitQuest,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, double.infinity),
                      textStyle: TextStyle(
                        // 👈 makes the text larger and bolder
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ),

            if (!_photoCaptured)
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                child: Text(
                  'Double tap the screen to take a photo',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
