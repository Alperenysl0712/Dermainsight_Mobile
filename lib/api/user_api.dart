import 'dart:developer';

import 'package:dermainsight/models/User.dart';
import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;


class UserApi{
  static Future<User?> getUserByUsername(String username, String password) async{
    final url = Uri.parse(AppConfig.getUserByUsernameUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'username': username,
      'password': password,
    });


    try{
      final response = await http.post(url, headers: headers, body: body);
      if(response.statusCode == 200){
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return User.fromJson(jsonData);
      }
      log('❌ Sunucu hatası: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      log('🔴 Hata: $e');
      return null;
    }
  }

  static Future<User?> register(User user) async{
    final url = Uri.parse(AppConfig.registerUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(user.toJson());
    log("➡️ JSON String (Register): $body");

    try{
      final response = await http.post(url, headers: headers, body: body);
      if(response.statusCode == 200){
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return User.fromJson(jsonData);
      }
      log('❌ Sunucu hatası: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      log('🔴 Hata: $e');
      return null;
    }
  }

  static Future<List<User>?> getPatientsByDoctor(int id) async{
    final url = Uri.parse(AppConfig.getPatientsByDoctorUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'doctor_id': id,
    });
    log("➡️ JSON String (PatientByDoc): $body");

    try{
      final response = await http.post(url, headers: headers, body: body);
      if(response.statusCode == 200){
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        log(jsonData.toString());
        return jsonData.map((e) => User.fromJson(e)).toList();
      }
      log('❌ Sunucu hatası: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      log('🔴 Hata: $e');
      return null;
    }
  }

  static Future<List<User>?> getPatients() async{
    final url = Uri.parse(AppConfig.getPatientsUrl);
    try{
      final response = await http.get(url);

      if(response.statusCode == 200){
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return jsonData.map((e) => User.fromJson(e)).toList();

      } else {
        log('❌ Sunucu hatası: ${response.statusCode} - ${response.body}');
        return null;
      }
    }catch (e) {
      log('🔴 Hata: $e');
      return null;
    }
  }
}