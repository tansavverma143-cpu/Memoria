import 'dart:convert';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/constants/constants.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();
  
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  
  // Auto-categorization logic
  static String detectCategory(String text, ItemType type) {
    final lowerText = text.toLowerCase();
    
    // Category detection based on keywords
    final Map<String, List<String>> categoryKeywords = {
      'Bills': ['bill', 'invoice', 'payment', 'due', 'amount', 'total'],
      'Receipts': ['receipt', 'purchase', 'store', 'shop', 'market'],
      'Study Notes': ['study', 'note', 'lecture', 'class', 'exam', 'test'],
      'Tasks': ['todo', 'task', 'reminder', 'deadline', 'complete'],
      'IDs': ['id', 'passport', 'license', 'aadhaar', 'pan', 'voter'],
      'Certificates': ['certificate', 'degree', 'diploma', 'award'],
      'Travel Documents': ['travel', 'ticket', 'flight', 'hotel', 'booking'],
      'Medical': ['medical', 'doctor', 'hospital', 'prescription', 'medicine'],
      'Financial': ['bank', 'account', 'loan', 'investment', 'stock'],
      'Work': ['work', 'office', 'meeting', 'project', 'report'],
      'Education': ['school', 'college', 'university', 'education', 'learn'],
    };
    
    // Check each category
    for (final entry in categoryKeywords.entries) {
      if (entry.value.any((keyword) => lowerText.contains(keyword))) {
        return entry.key;
      }
    }
    
    // Fallback based on item type
    switch (type) {
      case ItemType.bill:
        return 'Bills';
      case ItemType.receipt:
        return 'Receipts';
      case ItemType.id:
        return 'IDs';
      case ItemType.certificate:
        return 'Certificates';
      case ItemType.note:
        return 'Study Notes';
      case ItemType.task:
        return 'Tasks';
      default:
        return 'Other';
    }
  }
  
  // Extract tags from text
  static List<String> extractTags(String text) {
    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final commonWords = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by'};
    
    // Filter out common words and get unique words
    final tags = words
        .where((word) => word.length > 3 && !commonWords.contains(word))
        .toSet()
        .take(5) // Limit to 5 tags
        .toList();
    
    return tags;
  }
  
  // Detect dates in text for reminders
  static DateTime? detectDate(String text) {
    final datePatterns = [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})'),
      RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})'),
      RegExp(r'(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{4})', caseSensitive: false),
    ];
    
    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          // Parse date from match
          // This is simplified - in production, use a proper date parser
          return DateTime.now().add(const Duration(days: 7)); // Example: set reminder for 7 days later
        } catch (e) {
          return null;
        }
      }
    }
    
    return null;
  }
  
  // NLP Smart Search
  static List<SavedItem> smartSearch(List<SavedItem> items, String query) {
    final lowerQuery = query.toLowerCase();
    
    // Check for specific patterns
    if (lowerQuery.contains('passport') || lowerQuery.contains('id card')) {
      return items.where((item) => 
        item.type == ItemType.id || 
        item.title.toLowerCase().contains('passport') ||
        item.content.toLowerCase().contains('passport')
      ).toList();
    }
    
    if (lowerQuery.contains('bill') || lowerQuery.contains('invoice')) {
      return items.where((item) => 
        item.type == ItemType.bill || 
        item.detectedCategory == 'Bills' ||
        item.title.toLowerCase().contains('bill')
      ).toList();
    }
    
    if (lowerQuery.contains('receipt')) {
      return items.where((item) => 
        item.type == ItemType.receipt || 
        item.detectedCategory == 'Receipts' ||
        item.content.toLowerCase().contains('receipt')
      ).toList();
    }
    
    if (lowerQuery.contains('last month')) {
      final lastMonth = DateTime.now().subtract(const Duration(days: 30));
      return items.where((item) => 
        item.createdAt.isAfter(lastMonth)
      ).toList();
    }
    
    if (lowerQuery.contains('handwritten')) {
      return items.where((item) => 
        item.tags.contains('handwritten') ||
        item.content.toLowerCase().contains('handwritten')
      ).toList();
    }
    
    // Fallback to regular search
    return items.where((item) => 
      item.title.toLowerCase().contains(lowerQuery) ||
      item.content.toLowerCase().contains(lowerQuery) ||
      item.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
      (item.detectedCategory?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
  
  // OCR Processing
  Future<String> processImageWithOCR(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String fullText = '';
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          fullText += '${line.text}\n';
        }
      }
      
      return fullText.trim();
    } catch (e) {
      return '';
    }
  }
  
  // Text-to-Speech
  Future<void> speakText(String text) async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }
  
  // Speech-to-Text
  Future<String> startListening() async {
    bool available = await _speechToText.initialize();
    
    if (!available) {
      return 'Speech recognition not available';
    }
    
    String recognizedText = '';
    
    await _speechToText.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
      },
    );
    
    return recognizedText;
  }
  
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
  
  void dispose() {
    _textRecognizer.close();
    _tts.stop();
  }
}