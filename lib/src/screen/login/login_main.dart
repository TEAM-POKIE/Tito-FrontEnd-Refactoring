import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:tito_app/src/view/login/login_main/login_buttons_view.dart';
import 'package:tito_app/src/view/login/login_main/login_footer_view.dart';
import 'package:tito_app/src/view/login/login_main/login_header_view.dart';
import 'package:tito_app/src/viewModel/login/social_login_view_model.dart';

class LoginMain extends ConsumerStatefulWidget {
  const LoginMain({super.key});

  @override
  ConsumerState<LoginMain> createState() => _LoginMainState();
}

class _LoginMainState extends ConsumerState<LoginMain> {
  DateTime? lastBackPressedTime;

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(socialLoginViewModelProvider);

    return WillPopScope(
      onWillPop: () async {
        final shouldExit =
            await viewModel.handleBackPress(context, lastBackPressedTime);
        if (shouldExit) {
          SystemNavigator.pop();
        }
        setState(() {
          lastBackPressedTime = DateTime.now();
        });
        return false;
      },
      child: Scaffold(
        backgroundColor: ColorSystem.purple,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoginHeaderView(),
              SizedBox(height: 102.h),
              const LoginButtonsView(),
              SizedBox(height: 50.h),
              const LoginFooterView(),
            ],
          ),
        ),
      ),
    );
  }
}
