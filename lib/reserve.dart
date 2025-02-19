import 'package:flutter/material.dart';

import 'AppDrawer.dart';

class ReservePage extends StatelessWidget {
  const ReservePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("예약", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: const Image(
                    image: AssetImage("assets/images/reserve_logo.png"),
                    width: 70,
                    height: 70
                )
            ),
            const SearchBar(
                trailing: [Icon(Icons.search)],
                constraints: BoxConstraints(maxWidth: 300, minHeight: 50)
            ),
            Container(
                margin: const EdgeInsets.only(top: 20),
                width: 300,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column (
                  children: [
                    const Text("1호관 203호"),
                    const Text("시간: 3시 ~ 4시"),
                    ElevatedButton(
                        onPressed: () {
                          print("예약 버튼 클릭");
                        },
                        child: const Text("예약하기")
                    ),
                  ],
                ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: 300,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column (
                children: [
                  const Text("1호관 203호"),
                  const Text("시간: 3시 ~ 4시"),
                  ElevatedButton(
                      onPressed: () {
                        print("예약 버튼 클릭");
                      },
                      child: const Text("예약하기")
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: 300,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column (
                children: [
                  const Text("1호관 203호"),
                  const Text("시간: 3시 ~ 4시"),
                  ElevatedButton(
                      onPressed: () {
                        print("예약 버튼 클릭");
                      },
                      child: const Text("예약하기")
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: 300,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column (
                children: [
                  const Text("1호관 203호"),
                  const Text("시간: 3시 ~ 4시"),
                  ElevatedButton(
                      onPressed: () {
                        print("예약 버튼 클릭");
                      },
                      child: const Text("예약하기")
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
