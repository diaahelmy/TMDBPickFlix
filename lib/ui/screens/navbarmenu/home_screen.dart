import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HomeScreen')),
      body: Center(
        child: Text(
          'Home Screen Page',
          style: TextStyle(fontWeight: FontWeight.bold,
          fontSize: 16.h),
        ),
      ),
    );
  }
}
