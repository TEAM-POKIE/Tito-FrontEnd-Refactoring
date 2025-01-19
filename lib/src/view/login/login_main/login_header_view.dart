import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginHeaderView extends StatelessWidget {
  const LoginHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 146.h),
        Image.asset(
          'assets/images/splashs.png',
          width: 162.w,
          height: 127.29.h,
        ),
      ],
    );
  }
}
