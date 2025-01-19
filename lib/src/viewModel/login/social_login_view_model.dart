import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tito_app/core/api/api_service.dart';
import 'package:tito_app/core/api/dio_client.dart';
import 'package:tito_app/core/provider/login_provider.dart';
import 'package:tito_app/core/utils/secure_storage.dart';

final socialLoginViewModelProvider =
    Provider((ref) => SocialLoginViewModel(ref));

class SocialLoginViewModel {
  final Ref _ref;

  SocialLoginViewModel(this._ref);

  Future<void> signInWithGoogle(BuildContext context) async {
    final _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('User canceled Google Sign-In');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String accessToken = googleAuth.accessToken!;
      final String idToken = googleAuth.idToken!;

      await SecureStorageUtils.setAccessToken(accessToken);
      await SecureStorageUtils.setRefreshToken(idToken);

      final String fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      final authResponse = await ApiService(DioClient.dio).oAuthGoogle({
        "accessToken": accessToken,
        'fcmToken': fcmToken,
      });

      await DioClient.setToken(authResponse.accessToken.token);
      final userInfo = await ApiService(DioClient.dio).getUserInfo();
      final loginInfoNotifier = _ref.read(loginInfoProvider.notifier);
      loginInfoNotifier.setLoginInfo(userInfo);

      if (!context.mounted) return;
      context.go('/home');
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
    }
  }

  Future<void> signInWithKakao(BuildContext context) async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      await SecureStorageUtils.setAccessToken(token.accessToken);
      await SecureStorageUtils.setRefreshToken(token.idToken ?? '');

      final authResponse = await ApiService(DioClient.dio).oAuthKakao({
        "accessToken": token.accessToken,
        'fcmToken': await FirebaseMessaging.instance.getToken() ?? ''
      });

      await DioClient.setToken(authResponse.accessToken.token);
      final userInfo = await ApiService(DioClient.dio).getUserInfo();
      final loginInfoNotifier = _ref.read(loginInfoProvider.notifier);
      loginInfoNotifier.setLoginInfo(userInfo);

      if (!context.mounted) return;
      context.go('/home');
    } catch (error) {
      debugPrint('카카오 로그인 실패: $error');
      if (error is! PlatformException || error.code != 'CANCELED') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그인 실패: $error')),
          );
        }
      }
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'titoApp.example.com',
          redirectUri: Uri.parse('https://dev.tito.lat/oauth/apple'),
        ),
        nonce: 'example-nonce',
        state: 'example-state',
      );

      if (credential.identityToken == null) {
        debugPrint('Error: Apple identity token is null');
        return;
      }

      final authResponse = await ApiService(DioClient.dio).oAuthApple({
        "accessToken": credential.identityToken!,
        'fcmToken': await FirebaseMessaging.instance.getToken() ?? ''
      });

      await DioClient.setToken(authResponse.accessToken.token);
      final userInfo = await ApiService(DioClient.dio).getUserInfo();
      final loginInfoNotifier = _ref.read(loginInfoProvider.notifier);
      loginInfoNotifier.setLoginInfo(userInfo);

      if (!context.mounted) return;
      context.go('/home');
    } catch (e) {
      debugPrint('Error during Apple sign in: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple 로그인 실패: $e')),
        );
      }
    }
  }

  void goBasicLogin(BuildContext context) {
    context.push('/basicLogin');
  }

  void goSignUp(BuildContext context) {
    context.push('/signup');
  }

  Future<bool> handleBackPress(
      BuildContext context, DateTime? lastBackPressedTime) async {
    if (lastBackPressedTime == null ||
        DateTime.now().difference(lastBackPressedTime) > Duration(seconds: 2)) {
      Fluttertoast.showToast(msg: '뒤로 가기를 한번 더 누르면 종료됩니다.');
      return false;
    }
    return true;
  }
}
