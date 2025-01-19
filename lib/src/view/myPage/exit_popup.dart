import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tito_app/core/api/api_service.dart';
import 'package:tito_app/core/api/dio_client.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tito_app/core/provider/nav_provider.dart';
import 'package:tito_app/src/screen/login/login_main.dart';
import 'package:tito_app/core/utils/secure_storage.dart';

class ExitPopup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void putQuit() async {
      await ApiService(DioClient.dio).putQuit();
      await SecureStorageUtils.deleteAllTokens();
      final notifier = ref.read(selectedIndexProvider.notifier);
      notifier.state = 0;
      context.go('/login');
    }

    return Dialog(
      backgroundColor: ColorSystem.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        width: 280.w,
        height: 300.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 중앙에 배치되도록 설정
          crossAxisAlignment: CrossAxisAlignment.center, // 가로축에서 중앙 정렬
          children: <Widget>[
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/icons/popup_face.svg',
                      width: 40.w,
                      height: 40.h,
                    ),
                  ],
                ),
                Positioned(
                  top: -18.h,
                  right: 0.w,
                  child: IconButton(
                    iconSize: 20,
                    icon: const Icon(Icons.close, color: ColorSystem.grey),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              '정말로 회원 탈퇴 하시겠습니까?',
              style: FontSystem.KR18B,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h), // 상단 텍스트와 회색 박스 사이에 간격 추가
            Center(
              child: Container(
                width: 248.w,
                decoration: BoxDecoration(
                  color: ColorSystem.grey3,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 22.h),
                  child: Text(
                    '회원 탈퇴 하시면\n토론 기록과 관련 정보들이\n영영 사라져요',
                    style: FontSystem.KR14R,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h), // 회색 박스와 버튼 사이에 간격 추가
            Padding(
              padding: EdgeInsets.only(right: 20.w, left: 20.w),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorSystem.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  putQuit();
                },
                child: Container(
                  width: 241.w,
                  height: 40.h,
                  child: Center(
                    child: Text(
                      '회원 탈퇴하기',
                      style:
                          FontSystem.KR14R.copyWith(color: ColorSystem.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
