import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'AppDrawer.dart';
import 'api/api.dart';

class block_chain_mypage extends StatefulWidget {
  const block_chain_mypage({super.key});

  @override
  _block_chain_mypage createState() => _block_chain_mypage();
}

class _block_chain_mypage extends State<block_chain_mypage> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String result = "No data";

  String ethereumAddress = "";
  String? ethereum;
  String? sent_ethereum;
  String? received_ethereum;
  String? finish_ethereum;

  int? custNum;

  String? view_custNum;

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
          custNum_find_wallet(custNum!);
        });
        return;
      }
    }
  }

  Future<void> custNum_find_wallet(int custNum) async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/custNum_find_wallet'),
        body: json.encode({'custNum': custNum}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          ethereumAddress = jsonResponse['wallet'];
          getEther();
        });
      }
    } catch (e) {
    }
  }

  void getEther() {
    getBalance();
    viewTotalPaymentsByPayer();
    viewPaymentsByPayee();
    viewCustNumsPayee();
  }

  Future<void> viewItemKeysPayee() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/viewItemKeysPayee'),
        body: jsonEncode({
          'ethereumAddress' : ethereumAddress,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        double balance = double.parse(jsonResponse['balance']);
        String formattedBalance = balance.toStringAsFixed(2);
        setState(() {
          ethereum = formattedBalance as String?;
        });
      } else {
        setState(() {
          result = "Failed to make payment: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Future<void> getBalance() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/getBalance'),
        body: jsonEncode({
          'ethereumAddress' : ethereumAddress,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        double balance = double.parse(jsonResponse['balance']);
        String formattedBalance = balance.toStringAsFixed(2);
        setState(() {
          ethereum = formattedBalance as String?;
        });
      } else {
        setState(() {
          result = "Failed to make payment: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Future<void> viewTotalPaymentsByPayer() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/viewTotalPaymentsByPayer'),
        body: jsonEncode({
          'ethereumAddress' : ethereumAddress,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        double ether = double.parse(jsonResponse['ether']);
        String formattedEther = ether.toStringAsFixed(2);
        setState(() {
          sent_ethereum = formattedEther as String?;
        });
      } else {
        setState(() {
          result = "Failed to make payment: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Future<void> viewPaymentsByPayee() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/viewPaymentsByPayee'),
        body: jsonEncode({
          'ethereumAddress' : ethereumAddress,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        double ether = double.parse(jsonResponse['ether']);
        String formattedEther = ether.toStringAsFixed(2);
        setState(() {
          received_ethereum = formattedEther as String?;
        });
      } else {
        setState(() {
          result = "Failed to make payment: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Future<void> viewCustNumsPayee() async {
    try {
      final response = await http.post(
        Uri.parse(API.host + '/viewCustNumsPayee'),
        body: jsonEncode({
          'payeeAddress' : ethereumAddress,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          view_custNum = jsonResponse['viewCustNum'];
        });
      } else {
        setState(() {
          result = "Failed to make payment: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("블록체인 마이페이지", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '지갑 주소 : ',
              style: TextStyle(
                  fontSize: 25,
              ),
            ),
            Text(ethereumAddress),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { getEther(); },
              child: Text('확인'),
            ),
            SizedBox(height: 20),
            Text(
              ethereum != null ? "보유 이더 : $ethereum ETH" : "보유 이더 : 0 ETH",
              style: const TextStyle(
                fontSize: 25,
              ),
            ),
            Text(
              sent_ethereum != null ? "보류중인 보낸 이더 : $sent_ethereum ETH" : "보류중인 보낸 이더 : 0 ETH",
              style: const TextStyle(
                fontSize: 25,
              ),
            ),
            Text(
              received_ethereum != null ? "보류중인 받은 이더 : $received_ethereum ETH" : "보류중인 보낸 이더 : 0 ETH",
              style: const TextStyle(
                fontSize: 25,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/trade_sent'); },
              child: Text('보류중인 보낸 이더 확인'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/trade_received'); },
              child: Text('보류중인 받은 이더 확인'),
            ),
          ],
        ),
      ),
    );
  }
}