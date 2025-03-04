import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Text('login screen'),
      ),
    );
  }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: SafeArea(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SignInHeader(
//                 title: '로그인',
//                 subtitle: '다시 만나서 반가워요',
//               ),
//               const SizedBox(height: 48),
//               TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   labelText: '이메일',
//                   hintText: 'example@email.com',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return '이메일을 입력해주세요';
//                   }
//                   if (!value.contains('@')) {
//                     return '올바른 이메일 형식이 아닙니다';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: !_isPasswordVisible,
//                 decoration: InputDecoration(
//                   labelText: '비밀번호',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isPasswordVisible = !_isPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return '비밀번호를 입력해주세요';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: () {
//                   // TODO: 비밀번호 찾기 화면으로 이동
//                 },
//                 child: Text(
//                   '비밀번호 찾기',
//                 ),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _handleLogin,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 56),
//                 ),
//                 child: _isLoading
//                     ? const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 )
//                     : const Text('로그인'),
//               ),
//               const SizedBox(height: 16),
//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SignUpScreen(),
//                       ),
//                     );
//                   },
//                   child: RichText(
//                     text: TextSpan(
//                       style: Theme.of(context).textTheme.bodyMedium,
//                       children: [
//                         const TextSpan(text: '계정이 없으신가요? '),
//                         TextSpan(
//                           text: '회원가입',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
}
