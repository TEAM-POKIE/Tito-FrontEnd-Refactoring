import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:tito_app/src/viewModel/signUp/signup_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupFormView extends ConsumerWidget {
  const SignupFormView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(signupViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('닉네임', style: FontSystem.KR20SB),
        SizedBox(height: 10.h),
        TextFormField(
          maxLength: 10,
          decoration: InputDecoration(
            hintText: '닉네임을 입력해 주세요. (10글자 이하)',
            hintStyle: FontSystem.KR16M.copyWith(color: ColorSystem.grey),
            errorText: viewModel.nicknameError,
          ),
          validator: viewModel.validateNickname,
          onChanged: (value) => viewModel.setNickname(value),
        ),
        SizedBox(height: 30.h),
        Text('이메일', style: FontSystem.KR20SB),
        SizedBox(height: 10.h),
        TextFormField(
          maxLength: 20,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: '이메일을 입력해주세요',
            hintStyle: FontSystem.KR16M.copyWith(color: ColorSystem.grey),
            errorText: viewModel.emailError,
          ),
          validator: viewModel.validateEmail,
          onChanged: (value) => viewModel.setEmail(value),
        ),
        SizedBox(height: 30.h),
        Text('비밀번호', style: FontSystem.KR20SB),
        SizedBox(height: 10.h),
        TextFormField(
          maxLength: 20,
          obscureText: viewModel.obscureText,
          decoration: InputDecoration(
            hintText: '비밀번호 (영문, 숫자 조합 8자 이상)',
            hintStyle: FontSystem.KR16M.copyWith(color: ColorSystem.grey),
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.obscureText ? Icons.visibility_off : Icons.visibility,
                color: viewModel.obscureText
                    ? ColorSystem.grey
                    : ColorSystem.purple,
                size: 18.sp,
              ),
              onPressed: () => viewModel.togglePasswordVisibility(),
            ),
          ),
          validator: viewModel.validatePassword,
          onChanged: (value) => viewModel.setPassword(value),
        ),
      ],
    );
  }
}
