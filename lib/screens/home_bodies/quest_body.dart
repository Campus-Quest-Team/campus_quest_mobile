import 'package:camera/camera.dart';
import 'package:campus_quest/services/saved_credentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:campus_quest/services/camera.dart';
import 'package:campus_quest/api/posts.dart';
import 'package:campus_quest/services/login.dart';

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
  String? _questId;
  String? _questDescription;
  bool _isLoadingQuest = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadCurrentQuest();
  }

  Future<void> _initializeCamera() async {
    try {
      final controller = await initializeCamera();
      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _initializeControllerFuture = controller.initialize();
        _isCameraInitialized = true;
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
      final photo = await takeAndCropPhoto(_cameraController);
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

  @override
  void dispose() {
    _cameraController.dispose();
    _captionController.dispose();
    super.dispose();
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
                controller: tempController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Your thoughts...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cancel
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _captionController.text = tempController.text;
                      });
                      Navigator.of(context).pop();
                      _submitQuest(); // Submit after saving
                    },
                    child: const Text('Submit'),
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
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
              child: Container(
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
            ),
            SizedBox(height: 12.h),
            _isCameraInitialized
                ? Stack(
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
                                        child: CameraPreview(_cameraController),
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
                  )
                : const Center(child: CircularProgressIndicator()),
            SizedBox(height: 12.h),

            if (_photoCaptured)
              Expanded(
                child: TextField(
                  controller: _captionController,
                  readOnly: true,
                  onTap: () => _showCaptionDialog(context),
                  decoration: const InputDecoration(
                    labelText: 'Quest notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),

            if (!_photoCaptured)
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Take Photo"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFEFBF04), // Yellow
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
