import 'dart:convert';
import 'package:clover/trade_view.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:clover/api/api.dart';
import 'AppDrawer.dart';

class payment extends StatefulWidget {
  const payment({super.key});

  @override
  _payment createState() => _payment();
}

class _payment extends State<payment> {
  List tradeList = [];
  List filteredPosts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    t_list();
  }

  Future<void> t_list() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/t_list'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        setState(() {
          tradeList = json.decode(response.body)['results'];
          filteredPosts = List.from(tradeList);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showErrorDialog('커뮤니티 글을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorDialog('커뮤니티 글을 불러오는 동안 오류가 발생했습니다.');
    }
  }

  void handleSearch(String value) {
    if (value.length >= 2) {
      //filterPosts(value.toLowerCase());
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              content: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '두 글자 이상 입력해주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '닫기',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
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
    DateTime now = DateTime.now();
    Duration difference = now.difference(postDate);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${postDate.hour.toString().padLeft(2, '0')}:${postDate.minute
          .toString().padLeft(2, '0')}';
    } else if (difference.inDays < 30) {
      return '${postDate.month.toString().padLeft(2, '0')}/${postDate.day
          .toString().padLeft(2, '0')}';
    } else {
      return '${(difference.inDays / 365).floor()}년 전';
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('오류'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("거래 내역", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              constraints: BoxConstraints(maxWidth: 300, minHeight: 50),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: searchController,
                onSubmitted: handleSearch,
                decoration: const InputDecoration(
                  hintText: "검색어를 입력하세요",
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                return _buildCommunityPost(
                  filteredPosts[index]['itemKey'],
                  filteredPosts[index]['custNum'],
                  filteredPosts[index]['title'],
                  filteredPosts[index]['name'],
                  filteredPosts[index]['image1'],
                  filteredPosts[index]['content'],
                  filteredPosts[index]['price'],
                  filteredPosts[index]['rdate'],
                  filteredPosts[index]['amous'],
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: SizedBox(
                width: 80,
                height: 40,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/trade_write');
                  },
                  child: const Text("상품 등록"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityPost(int itemKey, int custNum, String title,
      String name, String? image1, String content,
      int price, String rdate, String amous) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TradePage_view(itemKey: itemKey),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        content,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            _extractTime(rdate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const Text(
                            ' | ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          amous == 'Y'
                              ? const Text(
                            '익명',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                              : FutureBuilder<String>(
                            future: custNumFind(custNum),
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
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                );
                              } else {
                                return Text(
                                  snapshot.data ?? '오류',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (image1 != null && image1.isNotEmpty)
                  Container(
                    width: 70, // 원하는 너비
                    height: 70, // 원하는 높이
                    margin: const EdgeInsets.only(left: 10), // 왼쪽에 여백 추가
                    child: Image.network(
                      '${API.host}/$image1',
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
