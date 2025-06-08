import 'package:dermainsight/widgets/app_bar_widget.dart';
import 'package:dermainsight/widgets/doctor_info_widget.dart';
import 'package:dermainsight/widgets/patient_info_widget.dart';
import 'package:flutter/material.dart';

import '../managers/user_manager.dart';
import '../widgets/drawer_widget.dart';

class DiseaseInfoScreen extends StatelessWidget{
  final bool isDoctor = UserManager.activeUser!.UserType == "Doktor";
  DiseaseInfoScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBarWidget(),
      backgroundColor: Color(0xFFE1E1E1),
      body: !isDoctor ? PatientInfoWidget() : DoctorInfoWidget(),
    );
  }

}