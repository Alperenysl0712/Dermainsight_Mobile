import 'dart:developer';

import 'package:dermainsight/api/disease_api.dart';
import 'package:dermainsight/api/user_api.dart';
import 'package:dermainsight/managers/error_manager.dart';
import 'package:dermainsight/managers/user_manager.dart';
import 'package:dermainsight/models/Disease.dart';
import 'package:dermainsight/models/DiseaseInfo.dart';
import 'package:dermainsight/models/User.dart';
import 'package:dermainsight/screens/add_diagnosis_detail_screen.dart';
import 'package:dermainsight/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/drawer_widget.dart';

class AddDiagnosisScreen extends StatefulWidget {
  const AddDiagnosisScreen({super.key});

  @override
  State<AddDiagnosisScreen> createState() => _AddDiagnosisScreenState();
}

class _AddDiagnosisScreenState extends State<AddDiagnosisScreen> {
  List<User>? patientList;
  List<Disease>? diseaseList;
  String? selectedPatient;
  String? selectedDisease;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<User>? userList = await UserApi.getPatients();
    List<Disease>? disList = await DiseaseApi.getDiseases();
    setState(() {
      patientList = userList;
      diseaseList = disList;
    });
  }

  Future<void> _saveDisease() async {
    log(
      "Add_Diagnosis_Screen/Hastalık Geçmişi: {Hasta Adı: $selectedPatient, Hastalık: $selectedDisease}",
    );

    if(selectedPatient == null || selectedDisease == null){
      ErrorManager.show(context: context, title: "Teşhis Ekleme Hatası", message: "Teşhis ekelenebilmesi için gerekli bütün parametreler girilmelidir.");
      return;
    }

    DiseaseInfo? dI = await DiseaseApi.createDiseaseInfo(UserManager.activeUser!.Id.toString(), selectedPatient!, selectedDisease!);
    log("Eklenen teşhis bilgisi: $dI");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBarWidget(),
      backgroundColor: Color(0xFFE1E1E1),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hasta Adı Soyadı",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            _selectField(hintText: "Hastalar", patientList: patientList),
            SizedBox(height: 20),
            Text(
              "Hastalık İsimleri",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            _selectField(hintText: "Hastalıklar", diseaseList: diseaseList),
            SizedBox(height: 100),
            TextButton(
              onPressed: () {
                _saveDisease();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(vertical: 16, horizontal: 45),
                ),
              ),
              child: Text(
                "Kaydet",
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
    );
  }

  Widget _selectField({
    required String hintText,
    List<User>? patientList,
    List<Disease>? diseaseList,
  }) {
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
            key:
                patientList != null
                    ? const Key("patient_dropdown")
                    : const Key("disease_dropdown"),
            value: patientList != null ? selectedPatient : selectedDisease,
            hint: Text(hintText, style: TextStyle(fontSize: 18)),
            isExpanded: true,
            items:
                patientList != null
                    ? patientList.map((value) {
                      return DropdownMenuItem<String>(
                        value: value.Id.toString(),
                        child: Text(
                          "${value.Name} ${value.Surname}",
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                      );
                    }).toList()
                    : (diseaseList ?? []).map((value) {
                      return DropdownMenuItem<String>(
                        value: value.id.toString(),
                        child: Text(
                          "${DiseaseTr.disTrList[value.diseaseName]}",
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                      );
                    }).toList(),

            onChanged: (newValue) {
              setState(() {
                if (patientList != null) {
                  selectedPatient = newValue;
                  log("Add_Diagnosis_Screen/ Seçili Hasta: $selectedPatient");
                } else {
                  selectedDisease = newValue;
                  log(
                    "Add_Diagnosis_Screen/ Seçili Hastalık: $selectedDisease",
                  );
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) {
                      return FractionallySizedBox(
                        heightFactor: 0.91,
                        child: AddDiagnosisDetailScreen(
                          disease: diseaseList!.firstWhere((d) => d.id.toString() == selectedDisease),
                        ),
                      );
                    },
                  );

                }
              });
            },
          ),
        ),
      ),
    );
  }
}
