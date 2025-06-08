import 'package:dermainsight/api/user_api.dart';
import 'package:dermainsight/base_navigator.dart';
import 'package:dermainsight/managers/error_manager.dart';
import 'package:dermainsight/managers/user_manager.dart';
import 'package:dermainsight/screens/error_screen.dart';
import 'package:dermainsight/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import '../models/User.dart';
import 'main_menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userNameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkUser() async {
    String userName = _userNameController.text.toString();
    String password = _passwordController.text.toString();

    try{
      User? user = await UserApi.getUserByUsername(userName, password).timeout(const Duration(seconds: 3));

      if (!mounted) return;

      if (user != null) {
        log("Login_Screen: $user");
        UserManager.activeUser = user;
        BaseNavigator.pushReplacement(context, MainMenuScreen(), "/mainMenuScreen");
      } else {
        ErrorManager.show(
          context: context,
          title: "Kullanıcı Hatası",
          message: "Girilen bilgilere ait kullanıcı bulunamadı.",
        );
      }
    }catch (e){
      BaseNavigator.pushAndRemoveAll(context, LoginScreen(), "/loginScreen");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 120),
                child: Text(
                  "Dermainsight",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "Kullanıcı Adı",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(10),
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),

              SizedBox(height: 30),
              Text(
                "Şifre",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(10),
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  obscureText: true,
                ),
              ),

              SizedBox(height: 70),
              ElevatedButton(
                onPressed: () {
                  _checkUser();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(vertical: 16, horizontal: 45),
                  ),
                ),
                child: Text(
                  "Giriş",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  BaseNavigator.pushReplacement(context, RegisterScreen(), "/registerScreen");
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                  ),
                ),
                child: Text(
                  "Kayıt Ol",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
