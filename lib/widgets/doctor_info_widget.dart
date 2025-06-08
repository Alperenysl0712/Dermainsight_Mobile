import 'dart:developer';

import 'package:dermainsight/api/disease_api.dart';
import 'package:dermainsight/api/user_api.dart';
import 'package:dermainsight/managers/user_manager.dart';
import 'package:dermainsight/models/Disease.dart';
import 'package:dermainsight/models/DiseaseInfo.dart';
import 'package:dermainsight/models/User.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorInfoWidget extends StatefulWidget {
  const DoctorInfoWidget({super.key});

  @override
  State<StatefulWidget> createState() => DoctorInfoWidgetState();
}

class DoctorInfoWidgetState extends State<DoctorInfoWidget> {
  int? selectedPatientId;

  List<User>? patientList;
  List<DiseaseInfo>? diseaseInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async{
    List<User>? userList = await UserApi.getPatientsByDoctor(UserManager.activeUser!.Id!);
    setState(() {
      patientList = userList;
    });
  }

  Future<void> _getInfos() async{
    List<DiseaseInfo>? diseaseList = await DiseaseApi.getDiseaseInfo(selectedPatientId!);
    setState(() {
      diseaseInfo = diseaseList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: selectedPatientId,
              hint: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Hasta Adı",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              isExpanded: true,
              items: (patientList ?? []).map((item) {
                return DropdownMenuItem(
                  value: item.Id,
                  child: Text(
                    "${item.Name} ${item.Surname}",
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }).toList(),

              selectedItemBuilder: (context) {
                return (patientList ?? []).map((item) {
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "${item.Name} ${item.Surname}",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }).toList();
              },
              onChanged: (value) {
                setState(() {
                  selectedPatientId = value;
                  _getInfos();
                });
              },
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 15, bottom: 5, left: 10, right: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    "Hastalık İsmi",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Teşhis Tarihi",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: (diseaseInfo ?? []).map((item) {
                final String diseaseName = DiseaseTr.disTrList[item.disease!.diseaseName].toString();
                final DateTime date = item.diagnosisDate!;

                return Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 15, horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            diseaseName,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                            maxLines: 3,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            DateFormat('dd.MM.yyyy HH:mm').format(date),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ),
      ],
    );
  }
}
