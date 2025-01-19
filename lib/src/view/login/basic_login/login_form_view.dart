import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:tito_app/src/view/login/basic_login/components/login_text_field.dart';
import 'package:tito_app/src/viewModel/login/basic_login_view_model.dart';

class LoginFormView extends ConsumerStatefulWidget {
  const LoginFormView({super.key});

  @override
  ConsumerState<LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends ConsumerState<LoginFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  void _onLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    ref.read(basicLoginViewModelProvider).onLogin(context);
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(basicLoginViewModelProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoginTextField(
            label: '이메일',
            hintText: '로그인 시 사용됩니다',
            onSaved: (value) => viewModel.setEmail(value ?? ''),
          ),
          SizedBox(height: 50.h),
          LoginTextField(
            label: '비밀번호',
            hintText: '비밀번호 (영문, 숫자 조합 8자 이상)',
            isPassword: true,
            obscureText: _obscureText,
            onToggleObscureText: _toggleObscureText,
            onSaved: (value) => viewModel.setPassword(value ?? ''),
          ),
          SizedBox(height: 167.h),
          SizedBox(
            width: 350.w,
            height: 60.h,
            child: ElevatedButton(
              onPressed: _onLogin,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                backgroundColor: ColorSystem.black,
              ),
              child: Text(
                '로그인',
                style: FontSystem.KR20SB.copyWith(color: ColorSystem.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
