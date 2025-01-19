import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:tito_app/src/viewModel/login/social_login_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginFooterView extends ConsumerWidget {
  const LoginFooterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(socialLoginViewModelProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '아직 회원이 아니신가요?',
              style: FontSystem.KR14R,
            ),
            SizedBox(width: 3.w),
            InkWell(
              onTap: () => viewModel.goSignUp(context),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  '회원가입',
                  style: FontSystem.KR14SB.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(
              '소셜로그인으로 진행 시,',
              style: FontSystem.KR12R,
            ),
            InkWell(
              onTap: () async {
                final url = Uri.parse(
                    'https://www.notion.so/113b5a1edfe4804bb9aac7ff6d4bf34d');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  '개인정보처리방침',
                  style: FontSystem.KR12B.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            Text(
              '에 동의한 것으로 취급됩니다.',
              style: FontSystem.KR12R,
            )
          ],
        ),
      ],
    );
  }
}
