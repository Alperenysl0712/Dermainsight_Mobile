import 'dart:convert';

import 'package:dermainsight/models/Disease.dart';
import 'package:flutter/material.dart';

import '../widgets/drawer_widget.dart';

class AddDiagnosisDetailScreen extends StatelessWidget {
  final Disease disease;
  const AddDiagnosisDetailScreen({required this.disease, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      backgroundColor: Color(0xFFE1E1E1),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 70),
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // 👈 Daire yapmanın daha temiz yolu
                  color: disease.imageName == '' ? Colors.red : null,
                  image: disease.imageName != ''
                      ? DecorationImage(
                    image: MemoryImage(base64Decode(disease.imageName)),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "${DiseaseTr.disTrList[disease.diseaseName]}",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),
              ),

              SizedBox(height: 70),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  disease.diseaseDetail ?? "",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
