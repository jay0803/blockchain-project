import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(
            height: 100,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'MENU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('학생증'),
            onTap: () {
              Navigator.pushReplacementNamed (context, '/id');
            },
          ),
          ListTile(
            title: const Text('중고거래'),
            onTap: () {
              Navigator.pushReplacementNamed (context, '/trade');
            },
          ),
          ListTile(
            title: const Text('커뮤니티'),
            onTap: () {
              Navigator.pushReplacementNamed (context, '/comunity');
            },
          ),
          // ListTile(
          //   title: const Text('예약'),
          //   onTap: () {
          //     Navigator.pushReplacementNamed (context, '/reserve');
          //   },
          // ),
          // ListTile(
          //   title: const Text('블록체인 test'),
          //   onTap: () {
          //     Navigator.pushReplacementNamed (context, '/block');
          //   },
          // ),
          ListTile(
            title: const Text('마이페이지'),
            onTap: () {
              Navigator.pushReplacementNamed (context, '/block_mypage');
            },
          ),
          // ListTile(
          //   title: const Text('결제 내역'),
          //   onTap: () {
          //     Navigator.pushReplacementNamed (context, '/payment');
          //   },
          // ),
        ],
      ),
    );
  }
}