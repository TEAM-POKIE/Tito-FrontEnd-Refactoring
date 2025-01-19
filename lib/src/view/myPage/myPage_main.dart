import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tito_app/core/api/dio_client.dart';
import 'package:tito_app/core/provider/login_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:tito_app/core/api/api_service.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tito_app/src/view/myPage/exit_popup.dart';
import 'package:tito_app/src/view/myPage/logout_popup.dart';
import 'package:url_launcher/url_launcher.dart';

class MypageMain extends ConsumerStatefulWidget {
  const MypageMain({super.key});

  @override
  ConsumerState<MypageMain> createState() => _MypageMainState();
}

class _MypageMainState extends ConsumerState<MypageMain> {
  File? _image;
  final ImagePicker picker = ImagePicker();
  final Uri perseonalUri = Uri.parse(
      'https://nine-grade-d65.notion.site/113b5a1edfe4804bb9aac7ff6d4bf34d?pvs=4');
  final Uri ruleUri = Uri.parse(
      'https://nine-grade-d65.notion.site/113b5a1edfe480df8ed6ec813a9b2c64?pvs=4');
  final Uri contactUri = Uri.parse(
      'https://nine-grade-d65.notion.site/Portunecookie-113b5a1edfe4807bac88cab4c83d229a?pvs=4');

  Future<void> requestPermissions() async {
    await [Permission.camera, Permission.photos].request();
  }

  Future<void> getImage(ImageSource source) async {
    await requestPermissions();

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 여기서 파일을 올바르게 처리
      });

      try {
        File profileImage = File(_image!.path);

        var formData = FormData.fromMap({
          'profilePicture': await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split(Platform.pathSeparator).last,
          ),
        });

        await ApiService(DioClient.dio).putUpdatePicture(formData);

        final userInfoResponse = await ApiService(DioClient.dio).getUserInfo();

        final loginInfoNotifier = ref.read(loginInfoProvider.notifier);
        loginInfoNotifier.setLoginInfo(userInfoResponse);
      } catch (e) {
        print('Error updating profile picture: $e');
      }
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('카메라'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('회원탈퇴'),
          content: const Text('정말로 회원탈퇴를 하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('탈퇴'),
              onPressed: () {
                // Perform the account deletion operation here
                Navigator.of(context).pop();
                // Optionally, navigate to another screen after deletion
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginInfo = ref.watch(loginInfoProvider);

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Stack(
              clipBehavior: Clip.none, // 오버플로우 콘텐츠가 잘리지 않도록 설정 : 연필 수정 아이콘
              children: [
                loginInfo!.profilePicture != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          loginInfo.profilePicture!,
                        ),
                        radius: 35.r,
                      )
                    : SvgPicture.asset(
                        'assets/icons/default_profile_1.svg',
                        width: 80,
                        height: 80,
                      ),
                Positioned(
                  bottom: -12,
                  right: -12,
                  child: IconButton(
                    onPressed: () {
                      _showImagePickerOptions(context);
                    },
                    icon: SvgPicture.asset('assets/icons/final_edit_pen.svg',
                        width: 30, height: 30),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${loginInfo.nickname}',
                  style: FontSystem.KR24B,
                ),
                IconButton(
                  onPressed: () {
                    context.push('/nickname');
                  },
                  icon: Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child:
                        SvgPicture.asset('assets/icons/mypage_final_arrow.svg',
                            //width: 20,
                            height: 20),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: ColorSystem.lightPurple,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: ColorSystem.purple),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Text(
                          '승률',
                          style: FontSystem.KR18B
                              .copyWith(color: ColorSystem.purple),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          '${loginInfo.winningRate}',
                          style: FontSystem.KR18B
                              .copyWith(color: ColorSystem.purple),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '%',
                          style: FontSystem.KR18B
                              .copyWith(color: ColorSystem.purple),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '${loginInfo.debateTotalCount}전 | ${loginInfo.debateVictoryCount}승 | ${loginInfo.debateDefeatCount}패',
              style: FontSystem.KR18SB,
            ),
            SizedBox(height: 40.h),
            // Divider(thickness: 4),
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: ColorSystem.grey3,
                borderRadius: BorderRadius.circular(4.h),
              ),
            ),
            SizedBox(height: 30.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: Text(
                  '내 활동',
                  style: FontSystem.KR14B,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _buildListTile(
              context,
              title: '내가 참여한 토론',
              leading: Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: SvgPicture.asset(
                  'assets/icons/mypage_debate.svg',
                  width: 24.w,
                  height: 24.h,
                ),
              ),
              onTap: () => context.push('/mydebate'),
            ),
            _buildListTile(
              context,
              title: '차단 리스트',
              leading: Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: SvgPicture.asset(
                  'assets/icons/mypage_bann.svg',
                  width: 24.w,
                  height: 24.h,
                ),
              ),
              onTap: () => context.push('/myblock'),
            ),
            SizedBox(height: 30.h),
            Container(
              height: 6.h,
              margin: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(
                color: ColorSystem.grey3,
                borderRadius: BorderRadius.circular(4.h),
              ),
            ),
            SizedBox(height: 30.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: Text(
                  '설정',
                  style: FontSystem.KR14B,
                ),
              ),
            ),

            SizedBox(height: 20.h),
            _buildListTile(
              context,
              title: '비밀번호 변경',
              leading: Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: SvgPicture.asset(
                  'assets/icons/mypage_pw.svg',
                  width: 24.w,
                  height: 24.h,
                ),
              ),
              onTap: () => context.push('/password'),
            ),
            _buildListTile(
              context,
              title: '문의하기',
              leading: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: SvgPicture.asset(
                  'assets/icons/mypage_ask.svg',
                  width: 24.w,
                  height: 24.h,
                ),
              ),
              onTap: () async => await launchUrl(
                contactUri,
                mode: LaunchMode.inAppBrowserView,
              ),
            ),
            _buildListTile(
              context,
              title: '개인정보처리방침',
              leading: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: SvgPicture.asset(
                  'assets/icons/mypage_one.svg',
                  width: 24.w,
                  height: 24.h,
                ),
              ),
              onTap: () async => await launchUrl(
                perseonalUri,
                mode: LaunchMode.inAppBrowserView,
              ),
            ),
            _buildListTile(
              context,
              title: '이용약관',
              leading: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: SvgPicture.asset(
                  'assets/icons/mypage_two.svg',
                  width: 24.w,
                  height: 24.h,
                ),
              ),
              onTap: () async => await launchUrl(
                ruleUri,
                mode: LaunchMode.inAppBrowserView,
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LogoutPopup();
                      },
                    );
                  },
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(color: ColorSystem.grey),
                  ),
                ),
                const Text(
                  '|',
                  style: TextStyle(color: ColorSystem.grey),
                ),
                TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ExitPopup();
                        },
                      );
                    },
                    child: const Text(
                      '회원탈퇴',
                      style: TextStyle(color: ColorSystem.grey),
                    )),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    Widget? leading,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 11.h),
      child: Container(
        height: 60.h,
        width: 350.w,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0x669795A3),
              spreadRadius: 0,
              blurRadius: 4,
            )
          ],
          //border: Border.all(color: ColorSystem.grey),
          borderRadius: BorderRadius.circular(20.r),
          color: ColorSystem.white,
        ),
        child: ListTile(
          leading: leading,
          title: Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(title),
          ),
          trailing: Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: SvgPicture.asset(
              'assets/icons/mypage_real_arrow.svg',
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
