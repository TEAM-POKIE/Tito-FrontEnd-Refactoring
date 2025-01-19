import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tito_app/core/api/api_service.dart';
import 'package:tito_app/core/api/dio_client.dart';
import 'package:tito_app/core/constants/style.dart';
import 'package:tito_app/core/provider/login_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

final basicLoginViewModelProvider =
    ChangeNotifierProvider((ref) => BasicLoginViewModel(ref));

class BasicLoginViewModel extends ChangeNotifier {
  final Ref _ref;
  String _email = '';
  String _password = '';
  bool _obscureText = true;

  bool get obscureText => _obscureText;

  BasicLoginViewModel(this._ref);

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  Future<void> validateAndLogin(
      BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    await onLogin(context);
  }

  Future<void> onLogin(BuildContext context) async {
    try {
      final authResponse = await ApiService(DioClient.dio).signIn({
        'email': _email,
        'password': _password,
        'fcmToken': await FirebaseMessaging.instance.getToken() ?? '',
      });

      await DioClient.setToken(authResponse.accessToken.token);
      await secureStorage.write(
          key: 'API_ACCESS_TOKEN', value: authResponse.accessToken.token);
      await secureStorage.write(
          key: 'API_REFRESH_TOKEN', value: authResponse.refreshToken.token);

      final userInfoResponse = await ApiService(DioClient.dio).getUserInfo();

      final loginInfoNotifier = _ref.read(loginInfoProvider.notifier);
      loginInfoNotifier.setLoginInfo(userInfoResponse);

      if (!context.mounted) return;
      context.go('/home');
    } catch (error) {
      if (error is DioError && error.response?.statusCode == 400) {
        Fluttertoast.showToast(
          msg: "${error.response!.data['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: ColorSystem.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error occurred: $error'),
            ),
          );
        }
      }
    }
  }

  void goBack(BuildContext context) {
    context.pop();
  }

  void goSignUp(BuildContext context) {
    context.push('/signup');
  }
}
