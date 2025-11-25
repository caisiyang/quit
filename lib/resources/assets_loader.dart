import 'dart:convert';
import 'package:flutter/services.dart';

class AssetsLoader {
  static Future<List<String>> loadQuotes() async {
    final String response = await rootBundle.loadString('assets/data/quotes.json');
    final List<dynamic> data = json.decode(response);
    return data.cast<String>();
  }

  static Future<List<String>> loadFacts() async {
    final String response = await rootBundle.loadString('assets/data/facts.json');
    final List<dynamic> data = json.decode(response);
    return data.cast<String>();
  }
}
