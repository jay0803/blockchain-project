import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:clover/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageScreen();
}

class LoginPageScreen extends State<LoginPage> {
  var formKey = GlobalKey<FormState>();

  var id_Controller = TextEditingController();
  var password_Controller = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  login() async {
    final res = await http.post(
      Uri.parse(API.host + "/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id_Controller.text.trim(),
        'password': password_Controller.text.trim(),
      }),
    );
    if (res.statusCode == 200) {
      var resBody = json.decode(res.body);

      if (resBody['login_success']) {
        await storage.write(key: 'jwt_token', value: resBody['token']);
        Navigator.pushReplacementNamed(context, '/id');
      }
      else {
        Fluttertoast.showToast(msg: '이름 또는 비밀번호를 잘못 입력하였습니다. ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("로그인", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: const Image(
                    image: AssetImage("assets/images/team_clover_logo.png"),
                    width: 250,
                    height: 250,
                  ),
                ),
                Container(
                  width: 300.0,
                  child: TextFormField(
                    controller: id_Controller,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '아이디',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 300.0,
                  child: TextFormField(
                    controller: password_Controller,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '비밀번호',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      login();
                    },
                    child: const Text("로그인"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () {
                      print("카카오 로그인 버튼 클릭");
                    },
                    child: Ink(
                      width: 200,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/kakao_login_medium_narrow.png'),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      print("네이버 로그인 버튼 클릭");
                    },
                    child: Ink(
                      width: 200,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/btnG_naver.png'),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
