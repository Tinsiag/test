import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '登录界面',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    // 显示 "登陆中" 弹窗
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("登陆中"),
          content: Text("请稍候，正在登录 $username..."),
        );
      },
    );

    var headers = {'Content-Type': 'application/json'};
    try {
      // 发送登录请求
      var response = await http.post(
        Uri.parse('https://p1.650644.xyz:881/api/auth/login'),
        headers: headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      Navigator.pop(context); // 关闭 "登陆中" 弹窗

      if (response.statusCode == 200) {
        // 登录成功，将用户名和密码存储到本地
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('password', password);

        // 显示登录成功弹窗
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("登录成功"),
              content: Text("欢迎回来，$username！"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("确定"),
                ),
              ],
            );
          },
        );
      } else {
        // 登录失败，显示错误信息
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("登录失败"),
              content: Text("请检查您的用户名和密码。"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("重试"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      Navigator.pop(context); // 关闭 "登陆中" 弹窗
      // 处理网络错误或其他异常
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("错误"),
            content: Text("发生错误：$e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("确定"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF2F5),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '登录',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A3A3A),
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: '用户名',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '密码',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    backgroundColor: Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '登录',
                    style: TextStyle(fontSize: 18),
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
