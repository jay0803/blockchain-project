import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:clover/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class CommunityPage_write extends StatefulWidget {
  const CommunityPage_write({super.key});

  @override
  State<CommunityPage_write> createState() => CommunityPage_write_Screen();
}

class CommunityPage_write_Screen extends State<CommunityPage_write> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  int? custNum;
  String? university;
  String? name;
  String? email;
  bool isChecked = false;

  var title_Controller = TextEditingController();
  var content_Controller = TextEditingController();

  File? _image;
  final picker = ImagePicker();

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
          custNum = jsonResponse['user']['custNum'];
        });
        return;
      }
    }
    Navigator.pushReplacementNamed(context, '/login');
    Fluttertoast.showToast(msg: '로그인을 해주세요.');
  }

  Future<void> c_write() async {
    if (title_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '제목을 입력해주세요.');
      return;
    }
    if (content_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '내용을 입력해주세요.');
      return;
    }

    tokenCheck();

    var request = http.MultipartRequest('POST', Uri.parse(API.host + "/c_write"));
    request.headers.addAll({'Content-Type': 'multipart/form-data'});

    // 이미지 파일 추가
    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _image!.path,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    // 다른 필드 추가
    request.fields['title'] = title_Controller.text.trim();
    request.fields['content'] = content_Controller.text.trim();
    request.fields['btype'] = '0';
    request.fields['amous'] = isChecked ? 'Y' : 'N';
    request.fields['custNum'] = custNum.toString();

    var response = await request.send();
    if (response.statusCode == 200) {
      var resBody = await response.stream.bytesToString();
      var decodedResBody = json.decode(resBody);
      if (decodedResBody['write_success']) {
        Navigator.pushReplacementNamed(context, '/comunity');
      } else {
        Fluttertoast.showToast(msg: '글 작성에 실패했습니다.');
      }
    } else {
      Fluttertoast.showToast(msg: '서버에 연결할 수 없습니다.');
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void cancelImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("글쓰기", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: title_Controller,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: content_Controller,
              minLines: 2,
              maxLines: 50,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  '익명',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isChecked = newValue!;
                    });
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ),
              ],
            ),

            Stack(
              children: [
                _image != null
                    ? Image.file(
                  _image!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : Container(),
                if (_image != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        cancelImage();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () {
                    getImage();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
      Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: SizedBox(
          width: 80,
          height: 60,
          child: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            onPressed: () {
              c_write();
            },
            child: const Row(
              children: [
                SizedBox(width: 8),
                Icon(Icons.edit),
                Text('글쓰기'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
