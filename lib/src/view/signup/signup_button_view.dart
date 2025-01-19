import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tito_app/core/constants/style.dart';

class SignupButtonView extends StatelessWidget {
  final VoidCallback onSignup;

  const SignupButtonView({
    super.key,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350.w,
      height: 60.h,
      child: ElevatedButton(
        onPressed: onSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: Text(
          '회원가입',
          style: FontSystem.KR20SB.copyWith(color: ColorSystem.white),
        ),
      ),
    );
  }
}
