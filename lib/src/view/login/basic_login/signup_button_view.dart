import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:tito_app/src/viewModel/login/basic_login_view_model.dart';

class SignupButtonView extends ConsumerWidget {
  const SignupButtonView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(basicLoginViewModelProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => viewModel.goSignUp(context),
          child: Text(
            '회원가입',
            style: FontSystem.KR16SB.copyWith(color: ColorSystem.purple),
          ),
        ),
      ],
    );
  }
}
