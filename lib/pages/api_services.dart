import 'package:http/http.dart' as http;

class OCRAPIService {
  static final String apiUrl = 'https://api.example.com/ocr';  // Replace with the actual API URL

  static Future<String> processImage(String image) async {
    final response = await http.post(Uri.parse(apiUrl), body: {'image': image});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to process image. Status code: ${response.statusCode}');
    }
  }
}
