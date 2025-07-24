import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class QuestBody extends StatefulWidget {
  final VoidCallback onBackToFeedTap;

  const QuestBody({super.key, required this.onBackToFeedTap});

  @override
  State<QuestBody> createState() => _QuestBodyState();
}

class _QuestBodyState extends State<QuestBody> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo captured successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> quests = [
      {
        'title': 'Find the Lost Compass',
        'description': 'Locate the legendary compass hidden in the old forest.',
      },
      {
        'title': 'Defeat the Shadow Beast',
        'description':
            'Face your fears and conquer the beast beneath the ruins.',
      },
      {
        'title': 'Deliver the Secret Scroll',
        'description':
            'Travel to the Mystic Tower and hand over the scroll safely.',
      },
    ];

    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBackToFeedTap,
          ),
          title: const Text('Your Quests'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: Theme.of(context).appBarTheme.elevation,
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: quests.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final quest = quests[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest['title']!,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        quest['description']!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Started: ${quest['title']}'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Quest'),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.camera_alt, size: 24),
                            onPressed: _takePhoto,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
