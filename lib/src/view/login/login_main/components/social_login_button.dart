import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tito_app/core/constants/style.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final Color backgroundColor;
  final Color? textColor;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.backgroundColor,
    this.textColor = ColorSystem.black,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 327.w,
      height: 54.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24.w,
              height: 24.h,
            ),
            SizedBox(width: 8.w),
            Text(
              text,
              style: FontSystem.Login16M.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
