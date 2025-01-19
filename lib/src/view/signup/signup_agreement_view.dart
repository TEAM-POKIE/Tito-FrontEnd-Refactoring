import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupAgreementView extends StatelessWidget {
  final bool isChecked;
  final bool checkBoxError;
  final ValueChanged<bool?> onCheckboxChanged;

  const SignupAgreementView({
    super.key,
    required this.isChecked,
    required this.checkBoxError,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Uri perseonalUri = Uri.parse(
        'https://nine-grade-d65.notion.site/113b5a1edfe4804bb9aac7ff6d4bf34d?pvs=4');

    return Column(
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                launchUrl(
                  perseonalUri,
                  mode: LaunchMode.inAppBrowserView,
                );
              },
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  '개인정보 처리방침',
                  style: FontSystem.KR12B.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            Text(
              '에 동의하시겠습니까?(필수)',
              style: FontSystem.KR12B,
            ),
            Checkbox(
              value: isChecked,
              onChanged: onCheckboxChanged,
            ),
          ],
        ),
        if (checkBoxError)
          Text(
            '개인정보 처리방침에 동의하셔야 합니다.',
            style: TextStyle(color: Colors.red, fontSize: 12.sp),
          ),
      ],
    );
  }
}
