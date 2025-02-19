import 'package:clover/block_mypage.dart';
import 'package:clover/payment.dart';
import 'package:clover/trade_received.dart';
import 'package:clover/trade_sent.dart';
import 'package:clover/trade_write.dart';
import 'package:flutter/material.dart';
import 'package:clover/main_page.dart';
import 'package:clover/login.dart';
import 'package:clover/student_id.dart';
import 'package:clover/signup.dart';
import 'package:clover/trade.dart';
import 'package:clover/community.dart';
import 'package:clover/reserve.dart';
import 'package:clover/community_write.dart';

import 'block.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/' : (context) => const MainPage(),
        '/login' : (context) => const LoginPage(),
        '/id' : (context) => const StudentIdPage(),
        '/signup' : (context) => const SignUpPage(),
        '/trade' : (context) => const TradePage(),
        '/trade_write' : (context) => const TradePage_write(),
        '/trade_sent' : (context) => const TradePage_sent(),
        '/trade_received' : (context) => const TradePage_received(),
        '/comunity' : (context) => const CommunityPage(),
        '/reserve' : (context) => const ReservePage(),
        '/comunity_write' : (context) => const CommunityPage_write(),
        '/block' : (context) => const block_chain(),
        '/block_mypage' : (context) => const block_chain_mypage(),
        '/payment' : (context) => const payment(),
      },
    );
  }
}
