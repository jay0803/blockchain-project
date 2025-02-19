import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:clover/api/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'community_update.dart';

class TradePage_view extends StatefulWidget {
  const TradePage_view({Key? key, required this.itemKey}) : super(key: key);

  final int itemKey;

  @override
  State<TradePage_view> createState() => _TradePage_view();
}

class _TradePage_view extends State<TradePage_view> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  late Future<void> _tradeViewPostsFuture;
  int? v_itemKey;
  String? title;
  String? name;
  int? price;
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
    _tradeViewPostsFuture = t_view(widget.itemKey);
  }

  Future<void> t_view(int itemKey) async {
    final response = await http.post(
      Uri.parse(API.host + '/t_view'),
      body: json.encode({'itemKey': itemKey}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        v_itemKey = jsonResponse['result']['itemKey'];
        title = jsonResponse['result']['title'];
        name = jsonResponse['result']['name'];
        price = jsonResponse['result']['price'];
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
        body: json.encode({'boardKey': widget.itemKey}),
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

  void trade() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/t_trade'),
        body: json.encode({
          'custNum': custNum,
          'v_custNum': v_custNum,
          'price': price,
          'itemKey': v_itemKey.toString()
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: '구입하였습니다.');
        Navigator.pushReplacementNamed(context, '/trade');
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
        title: const Text("중고 거래", style: TextStyle(color: Colors.white)),
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
                    builder: (context) => CommunityPage_update(boardKey: widget.itemKey),
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
          future: _tradeViewPostsFuture,
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
              print(snapshot);
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
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '상품명 : ${name}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '가격 : ${price} ETH',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '${content}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      if (image1 != null && image1!.isNotEmpty)
                        Container(
                          width: 400, // 원하는 너비
                          height: 400, // 원하는 높이
                          child: Image.network(
                            '${API.host}/$image1',
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
          }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: SizedBox(
          width: 100,
          height: 50,
          child: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            onPressed: () {
              trade();
            },
            child: const Row(
              children: [
                SizedBox(width: 8),
                Icon(
                  Icons.shopping_cart,
                  color: Colors.white, // 아이콘 색을 흰색으로 변경
                ),
                Expanded( // 텍스트를 버튼의 남은 공간에 맞추기 위해 Expanded 사용
                  child: Text(
                    ' 구입하기',
                    style: TextStyle(color: Colors.white), // 텍스트 색을 흰색으로 변경
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
