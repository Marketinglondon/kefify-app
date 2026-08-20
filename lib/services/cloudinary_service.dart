import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';

class CloudinaryService {
  static Future<String?> subirFoto(File archivo) async {
    try {
      final uri = Uri.parse(AppConfig.cloudinaryUploadUrl);
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = AppConfig.cloudinaryUploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', archivo.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final regex = RegExp(r'"secure_url":"([^"]+)"');
        final match = regex.firstMatch(responseData);
        if (match != null) {
          return match.group(1)?.replaceAll(r'\/', '/');
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> subirVariasFotos(List<File> archivos) async {
    List<String> urls = [];
    for (var archivo in archivos) {
      final url = await subirFoto(archivo);
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }
}
