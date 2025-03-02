import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends GetxController {
/*
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    if (token != null) {
      try {
        final userId = await _userService.getUserId();
        if (userId != null) {
          // 사용자 정보 가져오기
          final userInfo = await _userService.getUserAllInfo(userId);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MapScreen(
                  initialUser: userInfo.user,
                ),
              ),
            );

        }
      } catch (e) {
        debugPrint('사용자 정보 로드 실패: $e');
        // 토큰이 있지만 사용자 정보를 가져오는데 실패한 경우
        await _userService.deleteToken();
      }
    } else {
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      final savedEmail = prefs.getString('email');

      if (rememberMe && savedEmail != null && mounted) {
        setState(() {
          _rememberMe = true;
          _emailController.text = savedEmail;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _userService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!response.success) {
        throw Exception(response.message ?? '로그인에 실패했습니다.');
      }

      // 토큰 저장
      await _userService.saveToken(response.accessToken);
      // userId 저장
      await _userService.saveUserId(response.userId);

      // 사용자 정보 가져오기
      final userInfo = await _userService.getUserAllInfo(response.userId);

      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', true);
        await prefs.setString('email', _emailController.text);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              initialUser: userInfo.user, // UserInfoResponse에서 User 객체만 전달
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
*/
}