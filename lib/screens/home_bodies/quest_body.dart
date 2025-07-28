import 'package:camera/camera.dart';
import 'package:campus_quest/services/saved_credentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:campus_quest/services/camera.dart';
import 'package:campus_quest/api/posts.dart';

class QuestBody extends StatefulWidget {
  final VoidCallback onBackToFeedTap;

  const QuestBody({super.key, required this.onBackToFeedTap});

  @override
  State<QuestBody> createState() => _QuestBodyState();
}

class _QuestBodyState extends State<QuestBody> {
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false;
  bool _photoCaptured = false;
  File? _savedImage;
  final TextEditingController _captionController = TextEditingController();
  String? _questId;
  String? _questDescription;
  bool _isLoadingQuest = true;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupCameraAndQuest();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (_cameraController != null) {
      _cameraController!.dispose().then((_) {
        _isCameraInitialized = false;
        _initializeCamera(_selectedCameraIndex);
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera([int cameraIndex = 0]) async {
    if (_cameras.isEmpty) return; // Make sure cameras are loaded

    try {
      final selectedCamera = _cameras[cameraIndex];
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
      );
      await controller.initialize();

      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _initializeControllerFuture = Future.value();
        _isCameraInitialized = true;
        _selectedCameraIndex = cameraIndex;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera init error: $e')));
    }
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      final photo = await takeAndCropPhoto(_cameraController!);
      setState(() {
        _savedImage = photo;
        _photoCaptured = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  void _submitQuest() async {
    if (_savedImage == null || _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a photo and write notes.')),
      );
      return;
    }

    final credentials = await getToken(context);

    final userId = credentials['userId']!;
    final jwtToken = credentials['accessToken']!;
    final questId = _questId ?? 'unknown';

    // Submit post with file directly (no more uploadMedia)
    final success = await submitQuestPost(
      context: context,
      userId: userId,
      questId: questId,
      caption: _captionController.text,
      questDescription: _questDescription ?? '',
      file: _savedImage!, // ✅ this is now passed as a File, not a URL
      jwtToken: jwtToken,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quest submitted successfully!')),
      );
      widget.onBackToFeedTap();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to submit quest.')));
    }
  }

  void _retakePhoto() {
    setState(() {
      _photoCaptured = false;
      _savedImage = null;
      _captionController.clear();
    });
  }

  Future<void> _loadCurrentQuest() async {
    final data = await getCurrentQuest();
    if (!mounted) return;
    setState(() {
      _questId = data?['questId'];
      _questDescription = data?['questDescription'] ?? 'Quest not found.';
      _isLoadingQuest = false;
    });
  }

  Future<void> _setupCameraAndQuest() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception("No cameras found.");
      }

      _selectedCameraIndex = 0;
      await _initializeCamera(_selectedCameraIndex);
      await _loadCurrentQuest();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Setup error: $e')));
    }
  }

  void _showCaptionDialog(BuildContext context) {
    final tempController = TextEditingController(text: _captionController.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter Quest Notes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEFBF04),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                controller: tempController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Your thoughts...'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _captionController.text = tempController.text;
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        final newIndex = (_selectedCameraIndex + 1) % _cameras.length;
        _cameraController?.dispose();
        _initializeCamera(newIndex);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onBackToFeedTap,
          ),
          title: const Text('Your Quest'),
          actions: [
            IconButton(icon: const Icon(Icons.check), onPressed: _submitQuest),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Speech bubble
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: _isLoadingQuest
                              ? const Center(child: CircularProgressIndicator())
                              : Text(
                                  _questDescription ?? 'No quest available.',
                                  style: TextStyle(
                                    fontSize: 25.sp,
                                    color: Colors.grey[800],
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: -10,
                          left: 24,
                          child: CustomPaint(
                            painter: _SpeechBubbleTailPainter(
                              color: Colors.white,
                            ),
                            size: const Size(20, 10),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 14.h,
                    ), // Small gap between bubble and camera
                    // Camera square (takes 1:1 space)
                    AspectRatio(
                      aspectRatio: 1,
                      child: _isCameraInitialized
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: _photoCaptured && _savedImage != null
                                      ? Image.file(
                                          _savedImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : OverflowBox(
                                          alignment: Alignment.center,
                                          maxWidth: double.infinity,
                                          maxHeight: double.infinity,
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: SizedBox(
                                              width:
                                                  _cameraController!
                                                      .value
                                                      .previewSize
                                                      ?.height ??
                                                  1,
                                              height:
                                                  _cameraController!
                                                      .value
                                                      .previewSize
                                                      ?.width ??
                                                  1,
                                              child: CameraPreview(
                                                _cameraController!,
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
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 120.h,
                      child: _photoCaptured
                          ? TextField(
                              style: const TextStyle(color: Colors.white),
                              controller: _captionController,
                              readOnly: true,
                              onTap: () => _showCaptionDialog(context),
                              decoration:
                                  const InputDecoration(
                                    hintText: 'Quest notes',
                                    filled: true,
                                    fillColor: Color(0xFF555555),
                                  ).applyDefaults(
                                    Theme.of(context).inputDecorationTheme,
                                  ),
                              maxLines: null,
                              expands: true,
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.top,
                            )
                          : Center(
                              child: GestureDetector(
                                onTap: _takePhoto,
                                child: Container(
                                  width: 72.w,
                                  height: 72.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[800]!,
                                      width: 4,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeechBubbleTailPainter extends CustomPainter {
  final Color color;
  _SpeechBubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
