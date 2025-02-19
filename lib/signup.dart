import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:clover/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => SignupScreen();
}

class SignupScreen extends State<SignUpPage> {
  //var formKey = GlobalKey<FormState>();

  var id_Controller = TextEditingController();
  var password_Controller = TextEditingController();
  var name_Controller = TextEditingController();
  var university_Controller = TextEditingController();
  var classOf_Controller = TextEditingController();
  var email_Controller = TextEditingController();
  var wallet_Controller = TextEditingController();

  register() async {
    if (id_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '아이디를 입력해주세요.');
      return;
    }
    if (id_Controller.text.trim().length < 5 || id_Controller.text.trim().length > 20) {
      Fluttertoast.showToast(msg: '아이디는 최소 5자, 최대 20자 입니다.');
      return;
    }
    if (password_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '비밀번호를 입력해주세요.');
      return;
    }
    if (password_Controller.text.trim().length < 8) {
      Fluttertoast.showToast(msg: '비밀번호는 최소 8자 이상 입력하세요.');
      return;
    }
    if (name_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '이름을 입력해주세요.');
      return;
    }
    if(university_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '학교를 입력해주세요.');
      return;
    }
    if(classOf_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '학번을 입력해주세요.');
      return;
    }
    if (email_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '이메일을 입력해주세요.');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email_Controller.text.trim())) {
      Fluttertoast.showToast(msg: '유효한 이메일을 입력해주세요.');
      return;
    }
    if (wallet_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '지갑 주소를 입력해주세요.');
      return;
    }

    final res = await http.post(
      Uri.parse(API.host + "/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id_Controller.text.trim(),
        'password': password_Controller.text.trim(),
        'name': name_Controller.text.trim(),
        'university': university_Controller.text.trim(),
        'class_of': classOf_Controller.text.trim(),
        'email': email_Controller.text.trim(),
        'wallet': wallet_Controller.text.trim(),
      }),
    );
    if (res.statusCode == 201) {
      var resBody = jsonDecode(res.body);

      if (resBody['register_success']) {
        Fluttertoast.showToast(msg: '회원가입 되었습니다.');
        Navigator.pushReplacementNamed(context, '/');
      }
    }
    else {
      Fluttertoast.showToast(msg: '이미 존재하는 회원입니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("회원 가입", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            //key: formKey,
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
                  margin: const EdgeInsets.only(bottom: 20),
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
                  margin: const EdgeInsets.only(bottom: 20),
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
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 300.0,
                  child: TextFormField(
                    controller: name_Controller,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '이름',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 300.0,
                  child: TextFormField(
                    controller: university_Controller,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '학교',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 300.0,
                  child: TextFormField(
                    controller: classOf_Controller,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '학번',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 300.0,
                  child: TextFormField(
                    controller: email_Controller,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '이메일',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 300.0,
                  child: TextFormField(
                    controller: wallet_Controller,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '지갑주소',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      register();
                    },
                    child: const Text("회원 가입"),
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
                          image: AssetImage('assets/images/kakao_login_medium_narrow.png'),
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