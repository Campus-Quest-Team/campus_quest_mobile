import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// class CameraPage extends StatelessWidget {
//   const CameraPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Icon(Icons.camera_alt, size: 100, color: Colors.grey),
//     );
//   }
// }
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _takePhoto());
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
      );
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to take photo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile == null
                ? const Icon(Icons.camera_alt, size: 150, color: Colors.grey)
                : Image.file(
                    File(_imageFile!.path),
                    height: 500,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
            const SizedBox(height: 20),
            if (_imageFile != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                    _takePhoto(); // re-open camera
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Retake Photo'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
