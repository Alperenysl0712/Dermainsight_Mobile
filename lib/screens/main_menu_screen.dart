import 'dart:developer';

import 'package:dermainsight/base_navigator.dart';
import 'package:dermainsight/managers/user_manager.dart';
import 'package:dermainsight/screens/3d_model_screen.dart';
import 'package:dermainsight/screens/add_diagnosis_screen.dart';
import 'package:dermainsight/screens/ai_screen.dart';
import 'package:dermainsight/screens/ar_effect_screen.dart';
import 'package:dermainsight/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/drawer_widget.dart';
import 'disease_info_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final bool isDoctor = UserManager.activeUser!.UserType == "Doktor";
  MainMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {

    final Map<String, Widget> baseScreens = {
      "AR Efekti": ArEffectScreen(),
      "3D Model": ThreeDModelScreen(),
      "Hasta Bilgileri": DiseaseInfoScreen(),
    };

    final Map<String, Widget> doctorOnlyScreens = {
      "Cilt Analizi (YZ)": AiScreen(),
      "Teşhis Ekle": AddDiagnosisScreen(),
    };

    final Map<Widget, String> pageRouteName= {
      ArEffectScreen() : "/arEffectScreen",
      ThreeDModelScreen() : "/3DModelScreen",
      DiseaseInfoScreen() : "/diseaseInfoScreen",
      AiScreen() : "/aiScreen",
      AddDiagnosisScreen() : "/addDiagnosisScreen"
    };

    final Map<String, Widget?> screenList = {
      ...baseScreens,
      if (isDoctor) ...doctorOnlyScreens,
    };

    return Scaffold(
      drawer: CustomDrawer(),
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBarWidget(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
        child: Wrap(
          spacing: 40,
          runSpacing: 30,
          children: screenList.entries.map((item) {
            String title = item.key;
            Widget targetScreen = item.value!;

            return Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFFF4F3F3),
              ),
              child: ElevatedButton(
                onPressed: (){
                  log("Main_Menu_Screen/Seçilen Buton: $title");
                  BaseNavigator.push(context, targetScreen, pageRouteName[targetScreen]);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFFF4F3F3)),
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide.none,
                    ),
                  ),
                ),
                child: Text(title, style: TextStyle(fontSize: 14, color: Colors.black87),),
              ),
            );
      }).toList(),
        ),
      ),
    );
  }
}
