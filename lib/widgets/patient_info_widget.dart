import 'package:dermainsight/managers/user_manager.dart';
import 'package:dermainsight/models/Disease.dart';
import 'package:dermainsight/models/DiseaseInfo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/disease_api.dart';

class PatientInfoWidget extends StatefulWidget{
  const PatientInfoWidget({super.key});

  @override
  State<PatientInfoWidget> createState() => _PatientInfoWidgetState();
}

class _PatientInfoWidgetState extends State<PatientInfoWidget> {
  late List<DiseaseInfo>? diagnosisList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async{
    List<DiseaseInfo>? diseaseList = await DiseaseApi.getDiseaseInfo(UserManager.activeUser!.Id!);
    setState(() {
      diagnosisList = diseaseList;
    });

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding:  EdgeInsets.only(top: 15, bottom: 5, left: 10, right: 10),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Hastalık İsmi",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 3,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Doktor İsmi",
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
                  )
                ],
              ),
            ),
          ),


          ...(diagnosisList ?? []).map((item){
            final String diseaseName = DiseaseTr.disTrList[item.disease?.diseaseName].toString();
            final String doctorName = "${item.doctor?.Name} ${item.doctor?.Surname}";
            final DateTime date = item.diagnosisDate!;

            return Padding(
              padding:  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
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
                        doctorName,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('dd.MM.yyyy HH:mm').format(date),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    )
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}