import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

void main() async {
  // Load .env
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print("❌ API Key is missing in .env");
    exit(1);
  }

  print("🔍 Testing API Key: ${apiKey.substring(0, 5)}...");

  try {
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final response = await model.generateContent([Content.text('Say hello')]);
    print("✅ Success! Response: ${response.text}");
  } catch (e) {
    print("❌ Error with gemini-1.5-flash: $e");
    
    print("\n🔍 Attempting to list available models...");
    try {
      // Direct API call to list models is complex without a client, 
      // but let's try a different known name
      final model2 = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final response2 = await model2.generateContent([Content.text('Say hello')]);
      print("✅ 'gemini-pro' works! Response: ${response2.text}");
    } catch (e2) {
      print("❌ Error with gemini-pro: $e2");
      print("\n💡 Suggestion: Check if your API Key is valid and if your IP is from a supported region.");
    }
  }
}
