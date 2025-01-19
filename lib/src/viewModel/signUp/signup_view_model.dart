import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tito_app/core/api/api_service.dart';
import 'package:tito_app/core/api/dio_client.dart';

final signupViewModelProvider =
    ChangeNotifierProvider((ref) => SignupViewModel());

class SignupViewModel extends ChangeNotifier {
  String _email = '';
  String _nickname = '';
  String _password = '';
  bool _isChecked = false;
  bool _checkBoxError = false;
  bool _obscureText = true;
  String? _emailError;
  String? _nicknameError;

  bool get isChecked => _isChecked;
  bool get checkBoxError => _checkBoxError;
  bool get obscureText => _obscureText;
  String? get emailError => _emailError;
  String? get nicknameError => _nicknameError;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setIsChecked(bool value) {
    _isChecked = value;
    if (_isChecked) {
      _checkBoxError = false;
    }
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '닉네임을 입력해 주세요.';
    }
    if (value.length > 10) {
      return '닉네임은 10글자 이하로 적어주세요';
    }
    if (!RegExp(r'^[a-zA-Z0-9가-힣]+$').hasMatch(value)) {
      return '닉네임은 영문, 숫자, 한글만 사용할 수 있습니다.';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '올바른 이메일 형식을 입력해주세요';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 8 ||
        !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$')
            .hasMatch(value)) {
      return '비밀번호는 영문, 숫자 조합 8자 이상이어야 합니다.';
    }
    return null;
  }

  Future<bool> validateAndSignUp(
      BuildContext context, GlobalKey<FormState> formKey) async {
    if (!_isChecked) {
      _checkBoxError = true;
      notifyListeners();
      return false;
    }

    _checkBoxError = false;
    notifyListeners();

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      try {
        await signUp(context);
        return true;
      } catch (e) {
        if (e is SignupException) {
          if (e.message.contains('닉네임')) {
            _nicknameError = e.message;
          } else if (e.message.contains('이메일')) {
            _emailError = e.message;
          }
          notifyListeners();
        }
        return false;
      }
    }
    return false;
  }

  Future<void> signUp(BuildContext context) async {
    final signUpData = {
      'nickname': _nickname,
      'email': _email,
      'password': _password,
      'role': 'user',
    };

    final apiService = ApiService(DioClient.dio);

    try {
      await apiService.signUp(signUpData);
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 409) {
        final message = e.response?.data['message'] ?? '';
        throw SignupException(message);
      } else {
        throw SignupException('회원가입에 실패했습니다.');
      }
    }
  }

  void goBack(BuildContext context) {
    context.go('/login');
  }
}

class SignupException implements Exception {
  final String message;
  SignupException(this.message);
}
