import 'dart:convert';

import 'package:dermainsight/api/disease_api.dart';
import 'package:dermainsight/base_navigator.dart';
import 'package:dermainsight/managers/error_manager.dart';
import 'package:dermainsight/models/Disease.dart';
import 'package:dermainsight/screens/ar_effect_detail_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/app_bar_widget.dart';
import '../widgets/drawer_widget.dart';

class ArEffectScreen extends StatefulWidget{
  const ArEffectScreen({super.key});

  @override
  State<ArEffectScreen> createState() => _ArEffectScreenState();
}

class _ArEffectScreenState extends State<ArEffectScreen> {
  late List<Disease> diseaseLists = [];

  late Map<String, Widget?> diseaseMap;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async{
    List<Disease>? disList = await DiseaseApi.getDiseases();
    setState(() {
      diseaseLists = disList ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBarWidget(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 35),
          child: Wrap(
            spacing: 40,
            runSpacing: 30,
            children: (diseaseLists ?? []).map((item) {
              String title = DiseaseTr.disTrList[item.diseaseName].toString();
              return InkWell(
                onTap: () {
                  print("Ar Efekt: $title");
                  if(item.imageAr != null){
                    BaseNavigator.push(context, ArEffectDetailScreen(base64: item.imageAr!), "/arEffectDetailScreen");
                  }
                  else{
                    ErrorManager.show(context: context, title: "AR Efekt Hatası", message: "Ar Efekti göstrilirken hata oluştu.");
                  }
                },
                child: Container(
                  width: 150,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F3F3),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.maxFinite,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Image(
                          image: MemoryImage(base64Decode(item.imageName)),
                        ),
                      ),
                      Container(
                        width: double.maxFinite,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.black,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            title,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
    );
  }
}