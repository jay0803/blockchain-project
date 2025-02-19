import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:clover/api/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'community_update.dart';

class CommunityPage_view extends StatefulWidget {
  const CommunityPage_view({Key? key, required this.boardKey}) : super(key: key);

  final int boardKey;

  @override
  State<CommunityPage_view> createState() => _CommunityPage_view();
}

class _CommunityPage_view extends State<CommunityPage_view> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  late Future<void> _communityViewPostsFuture;
  String? title;
  String? content;
  String? rdate;
  String? amous;
  String? image1;
  int? v_custNum;
  int? custNum;

  @override
  void initState() {
    super.initState();
    tokenCheck();
    _communityViewPostsFuture = CommunityViewPosts(widget.boardKey);
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
        rdate = jsonResponse['result']['rdate'];
        amous = jsonResponse['result']['amous'];
        image1 = jsonResponse['result']['image1'];
        v_custNum = jsonResponse['result']['custNum'];
      });
    }
  }

  Future<String> custNumFind(int custNum) async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/custNum_find'),
        body: json.encode({'custNum': custNum}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['name'];
      } else {
        return '오류';
      }
    } catch (e) {
      return '오류';
    }
  }

  String _extractTime(String dateTime) {
    DateTime postDate = DateTime.parse(dateTime);

    return '${postDate.month.toString().padLeft(2, '0')}/${postDate.day.toString().padLeft(2, '0')} '
        '${postDate.hour.toString().padLeft(2, '0')}:${postDate.minute.toString().padLeft(2, '0')}';

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
  }

  Future<void> _confirmDelete(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("게시글 삭제"),
          content: const Text("정말로 이 게시글을 삭제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                // 삭제 함수 호출
                boardDelete();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void boardDelete() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/c_delete'),
        body: json.encode({'boardKey': widget.boardKey}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: '삭제 되었습니다..');
        Navigator.pushReplacementNamed(context, '/comunity');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '다시 시도해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("커뮤니티", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if(value == '신고') {

              } else if(value == '수정') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityPage_update(boardKey: widget.boardKey),
                  ),
                );
              } else if(value == '삭제') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (BuildContext context) {
              if (custNum == v_custNum) {
                return {'수정', '삭제'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              } else {
                return {'신고'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _communityViewPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('오류 발생: ${snapshot.error}'),
            );
          } else {
            return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  amous == 'Y'
                  ? const Text(
                    '작성자 : 익명',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ) : FutureBuilder<String>(
                          future: custNumFind(v_custNum!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 12,
                                width: 12,
                                child: CircularProgressIndicator(strokeWidth: 1),
                              );
                            } else if (snapshot.hasError) {
                              return const Text(
                                '오류',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                ),
                              );
                            } else {
                              return Text(
                                '작성자 : ${snapshot.data}' ?? '오류',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              );
                            }
                          },
                        ),
                  SizedBox(height: 10),
                  Text(
                    '${_extractTime(rdate!)}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 15),
                  Text(
                    '${title}',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    '${content}',
                    style: TextStyle(
                        fontSize: 18,
                    ),
                  ),
                  if (image1 != null && image1!.isNotEmpty)
                    Image.network(API.host + '/' + image1!),

                  ],
                ),
              ),
            );
          };
        }
      ),
    );
  }
}
