import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dermainsight/models/Disease.dart';
import 'package:dermainsight/models/DiseaseInfo.dart';
import 'package:dermainsight/models/Prediction.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../config.dart';

class DiseaseApi{
  static Future<List<DiseaseInfo>?> getDiseaseInfo(int id) async{
    final url = Uri.parse(AppConfig.getDiseaseInfoUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'patient_id': id,
    });
    log("➡️ JSON String (DiseaseInfo): $body");

    try{
      final response = await http.post(url, headers: headers, body: body);
      if(response.statusCode == 200){
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return jsonData.map((e) => DiseaseInfo.fromJson(e)).toList();

      }
      log('❌ Sunucu hatası: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      log('🔴 Hata: $e');
      return null;
    }
  }

  static Future<List<Disease>?> getDiseases() async{
    final url = Uri.parse(AppConfig.getDiseasesUrl);
    try{
      final response = await http.get(url);

      if(response.statusCode == 200){
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return jsonData.map((e) => Disease.fromJson(e)).toList();

      } else {
        log('❌ Sunucu hatası: ${response.statusCode} - ${response.body}');
        return null;
      }
    }catch (e) {
      log('🔴 Hata: $e');
      return null;
    }
  }

  static Future<DiseaseInfo?> createDiseaseInfo(String docId, String patId, String disId) async {
    final url = Uri.parse(AppConfig.createDiseaseInfoUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'DoctorId' : int.parse(docId),
      'PatientId' : int.parse(patId),
      'DiseaseId' : int.parse(disId)
    });
    log("➡️ JSON String (Register): $body");

    try{
      final response = await http.post(url, headers: headers, body: body);
      if(response.statusCode == 200){
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return DiseaseInfo.fromJson(jsonData);
      }
      log('❌ Sunucu hatası: ${response.statusCode} - ${response.body}');
      return null;
    }
    catch (e) {
      log('🔴 Hata: $e');
      return null;
    }
  }

  static Future<List<Prediction>> uploadImage(File image) async {
    try {
      final url = Uri.parse(AppConfig.uploadImageUrl);

      var request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: basename(image.path),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log("📡 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        log("Content/DA: $jsonData");
        List<Prediction> predictions = Prediction.fromJsonList(jsonData['predictions']);
        return predictions;
      } else {
        log("❌ Sunucu hatası: ${response.statusCode} - ${response.reasonPhrase}");
        throw Exception();
      }

    } catch (e, stackTrace) {
      log("🚨 Hata oluştu: $e");
      log("🧵 StackTrace: $stackTrace");
      return [];
    }
  }

  static Future<bool> createNewDisease(DiseaseUploadRequest request) async {
    final url = Uri.parse(AppConfig.createCsvUrl);
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode(request.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      log("🛰️ Status: ${response.statusCode}");
      log("📨 Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      log("🚨 Hata: $e");
      return false;
    }
  }


}