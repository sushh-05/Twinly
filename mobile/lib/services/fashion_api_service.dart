import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/fashion_garment.dart';
import '../models/fashion_profile.dart';

class FashionApiService {
  static Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');
  static const timeout = Duration(seconds: 20);

  Future<void> saveProfile(FashionProfile profile) async {
    try {
      await http
          .post(
            _uri('/api/profile'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(profile.toJson()),
          )
          .timeout(timeout);
    } catch (_) {}
  }

  Future<FashionGarment> analyzeUrl(String url) async {
    final response = await http
        .post(
          _uri('/api/garment/analyze'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'url': url}),
        )
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('analysis failed');
    }
    return FashionGarment.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body)['garment'] as Map),
    );
  }

  Future<FashionGarment> analyzeImage(Uint8List bytes, String filename) async {
    final request = http.MultipartRequest('POST', _uri('/api/garment/analyze'))
      ..files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: filename),
      );
    final response = await request.send().timeout(timeout);
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('analysis failed');
    }
    return FashionGarment.fromJson(
      Map<String, dynamic>.from(jsonDecode(body)['garment'] as Map),
    );
  }

  Future<String> generate({
    required FashionProfile profile,
    required FashionGarment garment,
    String? url,
    Uint8List? imageBytes,
    String? filename,
  }) async {
    http.Response? response;
    if (imageBytes != null) {
      final request = http.MultipartRequest(
        'POST',
        _uri('/api/tryon/generate'),
      );
      request.fields['profile'] = jsonEncode(profile.toJson());
      request.fields['garment'] = jsonEncode(garment.toJson());
      request.files.add(
        http.MultipartFile.fromBytes(
          'garmentImage',
          imageBytes,
          filename: filename ?? 'garment.jpg',
        ),
      );
      final streamed = await request.send().timeout(timeout);
      response = http.Response(
        await streamed.stream.bytesToString(),
        streamed.statusCode,
      );
    } else {
      response = await http
          .post(
            _uri('/api/tryon/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'profile': profile.toJson(),
              'garment': garment.toJson(),
              'garmentUrl': url,
            }),
          )
          .timeout(timeout);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('generation failed');
    }
    final imageUrl = jsonDecode(response.body)['imageUrl'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) throw Exception('missing image');
    return imageUrl;
  }

  Future<bool> health() async {
    try {
      final r = await http
          .get(_uri('/health'))
          .timeout(const Duration(seconds: 5));
      return r.statusCode >= 200 && r.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
