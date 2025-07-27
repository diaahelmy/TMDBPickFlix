import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SearchScreen'),
      ),
      body: Center(
        child: Text(
          'Search Screen Page',
          style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 16.h),
        ),
      ),
    );
  }
}
