import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:clover/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class CommunityPage_update extends StatefulWidget {
  const CommunityPage_update({Key? key, required this.boardKey}) : super(key: key);

  final int boardKey;

  @override
  State<CommunityPage_update> createState() => _CommunityPage_update();
}

class _CommunityPage_update extends State<CommunityPage_update> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  int? custNum;
  String? university;
  String? name;
  String? email;
  bool isChecked = false;

  late Future<void> _communityViewPostsFuture;
  late String title;
  late String content;
  late String rdate;
  String? amous;
  String? image1;
  late int v_custNum;

  var title_Controller = TextEditingController();
  var content_Controller = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    tokenCheck();
    _communityViewPostsFuture = CommunityViewPosts(widget.boardKey);
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

  Future<void> CommunityViewPosts(int boardKey) async {
    final response = await http.post(
      Uri.parse(API.host + '/c_view'),
      body: json.encode({'boardKey': boardKey}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        title = jsonResponse['result']['title'];
        content = jsonResponse['result']['content'];
        amous = jsonResponse['result']['amous'];
        image1 = jsonResponse['result']['image1'];
      });

      title_Controller.text = title ?? '';
      content_Controller.text = content ?? '';
    }
  }

  Future<void> c_update() async {
    if (title_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '제목을 입력해주세요.');
      return;
    }
    if (content_Controller.text.trim() == "") {
      Fluttertoast.showToast(msg: '내용을 입력해주세요.');
      return;
    }

    tokenCheck();

    var request = http.MultipartRequest('POST', Uri.parse(API.host + "/c_update"));
    request.headers.addAll({'Content-Type': 'multipart/form-data'});

    // 이미지 파일 추가
    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _image!.path,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    } else if (image1 != null) {
      // 서버와 클라이언트에서 사용할 수 있도록 image1을 필드에 추가
      request.fields['image1'] = image1!;
    }

    request.fields['title'] = title_Controller.text.trim();
    request.fields['content'] = content_Controller.text.trim();
    request.fields['amous'] = isChecked ? 'Y' : 'N';
    request.fields['boardKey'] = widget.boardKey.toString();

    var response = await request.send();
    if (response.statusCode == 200) {
      var resBody = await response.stream.bytesToString();
      var decodedResBody = json.decode(resBody);
      if (decodedResBody['update_success']) {
        Navigator.pushReplacementNamed(context, '/comunity');
      } else {
        Fluttertoast.showToast(msg: '글 수정에 실패했습니다.');
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
        image1 = null;
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
        title: const Text("글수정", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: title_Controller,
              decoration: InputDecoration(
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
              decoration: InputDecoration(
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
                  value: amous == 'Y',
                  onChanged: (bool? newValue) {
                    setState(() {
                      isChecked = newValue!;
                      amous = isChecked ? 'Y' : 'N';
                    });
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ),
              ],
            ),

            Stack(
              children: [
                if (_image != null || (image1 != null && image1!.isNotEmpty))
                  _image != null
                      ? Image.file(
                    _image!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                      : image1 != null
                      ? Image.network(
                    API.host + '/' + image1!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                      : Container(), // 이미지가 없으면 빈 컨테이너 표시
                if (_image != null || (image1 != null && image1!.isNotEmpty)) // 이미지가 있는 경우에만 제거 버튼 표시
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _image = null; // 이미지 제거
                          image1 = null; // 이미지 경로 제거
                        });
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
              c_update();
            },
            child: const Row(
              children: [
                SizedBox(width: 8),
                Icon(Icons.edit),
                Text('글수정'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
