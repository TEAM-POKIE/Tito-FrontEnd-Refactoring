import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:tito_app/src/view/signup/signup_agreement_view.dart';
import 'package:tito_app/src/view/signup/signup_button_view.dart';
import 'package:tito_app/src/view/signup/signup_form_view.dart';
import 'package:tito_app/src/viewModel/signUp/signup_view_model.dart';

class Signup extends ConsumerStatefulWidget {
  const Signup({super.key});

  @override
  ConsumerState<Signup> createState() => _SignupState();
}

class _SignupState extends ConsumerState<Signup> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(signupViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: ColorSystem.white,
        leading: IconButton(
          onPressed: () => viewModel.goBack(context),
          icon: SvgPicture.asset('assets/icons/back_arrow.svg'),
        ),
        title: const Text('회원가입'),
        titleTextStyle: FontSystem.KR16SB,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 105.h),
                const SignupFormView(),
                SignupAgreementView(
                  isChecked: viewModel.isChecked,
                  checkBoxError: viewModel.checkBoxError,
                  onCheckboxChanged: (value) =>
                      viewModel.setIsChecked(value ?? false),
                ),
                SizedBox(height: 60.h),
                SignupButtonView(
                  onSignup: () =>
                      viewModel.validateAndSignUp(context, _formKey),
                ),
                SizedBox(height: 44.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
