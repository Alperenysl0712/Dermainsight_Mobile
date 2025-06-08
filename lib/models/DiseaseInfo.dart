import 'Disease.dart';
import 'User.dart';

class DiseaseInfo {
  final int? id;
  final int? doctorId;
  final int patientId;
  final int diseaseName;
  final DateTime? diagnosisDate;

  final User? doctor;
  final User? patient;
  final Disease? disease;

  DiseaseInfo({
    this.id,
    this.doctorId,
    required this.patientId,
    required this.diseaseName,
    this.diagnosisDate,
    this.doctor,
    this.patient,
    this.disease,
  });

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    return DiseaseInfo(
      id: json['Id'] ?? 0,
      doctorId: json['DoctorId'] ?? -1,
      patientId: json['PatientId'] ?? -1,
      diseaseName: json['DiseaseId'] ?? -1,
      diagnosisDate: DateTime.parse(json['DiagnosisDate']),
      doctor: json['Doctor'] != null ? User.fromJson(json['Doctor']) : null,
      patient: json['Patient'] != null ? User.fromJson(json['Patient']) : null,
      disease: json['Disease'] != null ? Disease.fromJson(json['Disease']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'DoctorId': doctorId,
      'PatientId': patientId,
      'DiseaseId': diseaseName,
      'DiagnosisDate': diagnosisDate!.toIso8601String(),
      'Doctor': doctor?.toJson(),
      'Patient': patient?.toJson(),
      'Disease': disease?.toJson(),
    };
  }

  @override
  String toString() {
    return 'DiseaseInfo{\n'
        'id: $id, \n'
        'doctorId: $doctorId, \n'
        'patientId: $patientId, \n'
        'diseaseName: $diseaseName, \n'
        'diagnosisDate: $diagnosisDate\n'
        '}';
  }
}
