import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:tito_app/src/view/login/login_main/components/social_login_button.dart';
import 'package:tito_app/src/viewModel/login/social_login_view_model.dart';

class LoginButtonsView extends ConsumerWidget {
  const LoginButtonsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(socialLoginViewModelProvider);

    return Column(
      children: [
        SocialLoginButton(
          text: 'Google 계정으로 로그인',
          iconPath: 'assets/icons/google_new.svg',
          backgroundColor: Colors.white,
          textColor: ColorSystem.googleFont,
          onPressed: () => viewModel.signInWithGoogle(context),
        ),
        SizedBox(height: 10.h),
        SocialLoginButton(
          text: '카카오계정으로 로그인',
          iconPath: 'assets/icons/kakao_new.svg',
          backgroundColor: ColorSystem.kakao,
          onPressed: () => viewModel.signInWithKakao(context),
        ),
        SizedBox(height: 10.h),
        if (Platform.isIOS)
          Column(
            children: [
              SocialLoginButton(
                text: 'Apple로 로그인',
                iconPath: 'assets/icons/apple_new.svg',
                backgroundColor: ColorSystem.black,
                textColor: ColorSystem.white,
                onPressed: () => viewModel.signInWithApple(context),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        Container(
          width: 327.w,
          height: 54.h,
          child: ElevatedButton(
            onPressed: () => viewModel.goBasicLogin(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorSystem.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            child: Text(
              '이메일로 로그인',
              style: FontSystem.Login16M.copyWith(color: ColorSystem.white),
            ),
          ),
        ),
      ],
    );
  }
}
