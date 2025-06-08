import 'dart:async';
import 'dart:io';
import 'package:dermainsight/config.dart';
import 'package:http/http.dart' as http;

class FastApi {
  static Future<bool> checkFastApiHealth() async {
    final url = AppConfig.statusCheckUrl;
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        print('✅ API çalışıyor: ${response.body}');
        return true;
      } else {
        throw HttpException(
          'API ${response.statusCode} döndü: ${response.body}',
          uri: Uri.parse(url),
        );
      }
    } on TimeoutException catch (e) {
      throw TimeoutException('Zaman aşımı: $e');
    } on SocketException catch (e) {
      throw SocketException('İnternet bağlantı hatası: $e');
    } catch (e) {
      throw Exception('Bilinmeyen hata: $e');
    }
  }
}
