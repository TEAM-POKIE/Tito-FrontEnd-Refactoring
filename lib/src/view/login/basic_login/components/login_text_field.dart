import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tito_app/core/constants/style.dart';

class LoginTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final void Function(String?) onSaved;
  final bool obscureText;
  final VoidCallback? onToggleObscureText;

  const LoginTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.onSaved,
    this.isPassword = false,
    this.controller,
    this.obscureText = false,
    this.onToggleObscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FontSystem.KR20SB),
        SizedBox(height: 10.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: isPassword
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          autocorrect: false,
          style: FontSystem.KR16M,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: FontSystem.KR16M.copyWith(color: ColorSystem.grey),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color:
                          obscureText ? ColorSystem.grey : ColorSystem.purple,
                      size: 18.sp,
                    ),
                    onPressed: onToggleObscureText,
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '${label}을 입력해주세요';
            }
            return null;
          },
          onSaved: onSaved,
        ),
      ],
    );
  }
}
