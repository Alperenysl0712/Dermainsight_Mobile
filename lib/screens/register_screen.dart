import 'dart:developer';

import 'package:dermainsight/api/user_api.dart';
import 'package:dermainsight/base_navigator.dart';
import 'package:dermainsight/managers/error_manager.dart';
import 'package:dermainsight/models/User.dart';
import 'package:dermainsight/screens/login_screen.dart';
import 'package:flutter/material.dart';

import 'error_screen.dart';

class RegisterScreen extends StatefulWidget{
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => RegisterScreenState();

}

class RegisterScreenState extends State<RegisterScreen> {
  final List<TextEditingController> _controllers = List.generate(
      7,
      (index) => TextEditingController()
  );
  String? selectedValue;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
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
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Text("Kayıt Bilgileri", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),),
              ),

              _textFields(hintMessage: "İsim", controller: _controllers[0]),
              SizedBox(height: 15,),
              _textFields(hintMessage: "Soyisim", controller: _controllers[1]),
              SizedBox(height: 15,),
              _textFields(hintMessage: "Kullanıcı Adı", controller: _controllers[2]),
              SizedBox(height: 15,),
              _selectField(),
              SizedBox(height: 15,),
              _textFields(hintMessage: "E-Mail", controller: _controllers[3]),
              SizedBox(height: 15,),
              _textFields(hintMessage: "Telefon Numarası", controller: _controllers[4]),
              SizedBox(height: 15,),
              _textFields(hintMessage: "Şifre", controller: _controllers[5], obscureTexts: true),
              SizedBox(height: 15,),
              _textFields(hintMessage: "Şifre Tekrar", controller: _controllers[6], obscureTexts: true),
              SizedBox(height: 25,),
              GestureDetector(
                onTap: () {
                  BaseNavigator.pushReplacement(context, LoginScreen(), "/loginScreen");
                },
                child: Text(
                  "Hesabınız bulunuyor mu? Giriş Yapın",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),

              SizedBox(height: 35,),
              TextButton(
                onPressed: () {
                  checkInfoAndRegister();
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16, horizontal: 45),
                    )
                ),
                child: Text("Kayıt Ol", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFields({required String hintMessage, required TextEditingController controller, bool obscureTexts = false}){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        obscureText: obscureTexts,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintMessage,
          hintStyle: TextStyle(fontSize: 18),
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
    );
  }

  Widget _selectField(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [],
        ),
        width: double.infinity,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text("Hasta Tipi", style: TextStyle(fontSize: 18)),
            isExpanded: true,
            items: ["Hasta", "Doktor"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontSize: 18, color: Colors.black87)),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                log("Seçilen Tip: $newValue");
                selectedValue = newValue;
              });
            },
          ),
        ),
      ),
    );
  }

  void checkInfoAndRegister() async{
    for (final controller in _controllers) {
      if(controller.text.trim().isEmpty){
        ErrorManager.show(context: context, title: "Kayıt Hatası", message: "Kayıt için bilgilerin hepsini giriniz.");
        return;
      }
    }

    if(_controllers[5].text.trim() != _controllers[6].text.trim()){
      ErrorManager.show(context: context, title: "Kayıt Hatası", message: "Girdiğiniz şifreler uyuşmamaktadır.");
      return;
    }

    User user = User(
        Username: _controllers[2].text.trim(),
        Name: _controllers[0].text.trim(),
        Surname: _controllers[1].text.trim(),
        Email: _controllers[3].text.trim(),
        UserType: selectedValue.toString(),
        Phone: _controllers[4].text.trim(),
        Password: _controllers[6].text.trim()
    );


    try{
      User? controlUser = await UserApi.getUserByUsername(user.Username, user.Password).timeout(const Duration(seconds: 3));

      if (!mounted) return;

      if(controlUser != null){
        ErrorManager.show(context: context, title: "Kayıt Hatası", message: "Girilen bilgilere ait kullanıcı veritabanında bulunmaktadır.");
        return;
      }

      controlUser = await UserApi.register(user).timeout(const Duration(seconds: 3));


      if(controlUser != null){
        log("Register_Screen: $controlUser");
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
      }
      else{
        if (!mounted) return;
        ErrorManager.show(context: context, title: "Kayıt Hatası", message: "Kullanıcı kayıt edilirken hata oluştu.");
      }
    }catch (e){
      BaseNavigator.pushAndRemoveAll(context, RegisterScreen(), "/registerScreen");
    }
  }
}