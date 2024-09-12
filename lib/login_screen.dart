import 'package:flutter/material.dart';
import 'package:flutter_login_fix/flutter_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';
  String accessToken = '';

  Future<void> _login(context, LoginData loginData) async {
    username = loginData.name;
    password = loginData.password;

    final url = Uri.parse('https://focali-uat.azurewebsites.net/connect/token');

    try {
      var body = {
        'grant_type': 'password',
        'scope': 'offline_access AgencyPlatform',
        'username': username,
        'password': password,
        'client_id': 'AgencyPlatform_App',
        'client_secret': '1q2w3e',
      };

      final encodedBody = body.entries
          .map((entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
          .join('&');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': '*/*',
        },
        body: encodedBody,
      );

      debugPrint('RESPONSE >>> ${response.statusCode} \n${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        accessToken = responseData['access_token'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(accessToken: accessToken),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            content: Center(
              child: Text('Login Failed!'),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('CAUGHT EXCEPTION >>> ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: '',
      logo: const AssetImage('assets/images/logo.png'),
      userType: LoginUserType.text,
      hideForgotPasswordButton: true,
      disableCustomPageTransformer: true,
      userValidator: (_) => null,
      validateUserImmediately: true,
      onLogin: (loginData) {
        _login(context, loginData);
        return null;
      },
      savedEmail: username,
      savedPassword: password,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      },
      onRecoverPassword: (_) async {
        return null;
      },
      theme: LoginTheme(
        primaryColor: Colors.blue,
        accentColor: Colors.yellow,
        errorColor: Colors.red,
        titleStyle: const TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'Quicksand',
          letterSpacing: 4,
        ),
        bodyStyle: const TextStyle(
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
        ),
        textFieldStyle: const TextStyle(
          color: Colors.orange,
          shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
        ),
        buttonStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 5,
          margin: const EdgeInsets.only(top: 15),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: Colors.purple,
          backgroundColor: Colors.blue,
          highlightColor: Colors.lightGreen,
          elevation: 9.0,
          highlightElevation: 6.0,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
