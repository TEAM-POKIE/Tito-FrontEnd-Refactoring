import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tito_app/core/constants/style.dart';

import 'package:tito_app/src/view/login/basic_login/login_form_view.dart';
import 'package:tito_app/src/view/login/basic_login/signup_button_view.dart';
import 'package:tito_app/src/viewModel/login/basic_login_view_model.dart';

class BasicLogin extends ConsumerWidget {
  const BasicLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(basicLoginViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: ColorSystem.white,
        leading: IconButton(
          onPressed: () => viewModel.goBack(context),
          icon: SvgPicture.asset('assets/icons/back_arrow.svg'),
        ),
        title: const Text('로그인'),
        titleTextStyle: FontSystem.KR16SB,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 110.h),
              const LoginFormView(),
              SizedBox(height: 20.h),
              const SignupButtonView(),
            ],
          ),
        ),
      ),
    );
  }
}
