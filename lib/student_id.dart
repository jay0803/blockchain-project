import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:clover/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'AppDrawer.dart';

class StudentIdPage extends StatefulWidget {
  const StudentIdPage({super.key});

  @override
  State<StudentIdPage> createState() => _StudentIdPage();
}

class _StudentIdPage extends State<StudentIdPage> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? id;
  String? name;
  String? university;
  String? class_of;
  String? email;

  @override
  void initState() {
    super.initState();
    tokenCheck();
  }

  void tokenCheck() async {
    var token = await storage.read(key: 'jwt_token');
    if (token != null) {
      final response = await http.get(
        Uri.parse(API.host + "/profile"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          id = jsonResponse['user']['id'];
          name = jsonResponse['user']['name'];
          university = jsonResponse['user']['university'];
          class_of = jsonResponse['user']['class_of'];
          email = jsonResponse['user']['email'];
        });
        return;
      }
    }
    Navigator.pushReplacementNamed(context, '/');
    Fluttertoast.showToast(msg: '로그인을 해주세요.');
  }

  logout() async {
    await storage.delete(key: 'jwt_token');
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("학생증", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: const Image(
                image: AssetImage("assets/images/id_test_img.png"),
                width: 100,
                height: 100,
              ),
            ),
            Container(
              child: const Text(
                "학생증",
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            Container(
              child: const Image(
                image: AssetImage("assets/images/id_test_cat.jpg"),
                width: 200,
                height: 200,
              ),
            ),
            Container(
              child: const Image(
                image: AssetImage("assets/images/id_test_logo.jpg"),
                width: 200,
                height: 40,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              child: Text(
                university != null ? "아이디: $id" : "아이디: ",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Container(
              child: Text(
                name != null ? "이름: $name" : "이름: ",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Container(
              child: Text(
                  university != null ? "학교: $university" : "학교: ",
                  style: const TextStyle(fontSize: 20),
              ),
            ),
            Container(
              child: Text(
                university != null ? "학번: $class_of" : "학번: ",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Container(
              child: Text(
                  email != null ? "이메일: $email" : "이메일: ",
                  style: const TextStyle(fontSize: 20),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  logout();
                },
                child: const Text("로그아웃"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
