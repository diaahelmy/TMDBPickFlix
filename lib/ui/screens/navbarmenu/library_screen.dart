import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LibraryScreen'),

      ),
      body: Center(
        child: Text(
          'Library Screen Page',
          style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 16.h),
        ),
      ),
    );
  }
}
