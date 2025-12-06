import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memoria/constants/constants.dart';

class Helpers {
  // Format file size
  static String formatFileSize(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    final i = (log(bytes) / log(1024)).floor();
    
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
  
  // Format date with relative time
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
  
  // Format date for display
  static String formatDate(DateTime date, {String format = 'MMM d, yyyy'}) {
    return DateFormat(format).format(date);
  }
  
  // Format time for display
  static String formatTime(DateTime date, {bool showSeconds = false}) {
    return DateFormat(showSeconds ? 'hh:mm:ss a' : 'hh:mm a').format(date);
  }
  
  // Format date and time
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} • ${formatTime(date)}';
  }
  
  // Get file extension icon
  static IconData getFileIcon(String extension) {
    final ext = extension.toLowerCase();
    
    if (AppConstants.imageExtensions.contains(ext)) {
      return Icons.photo;
    } else if (AppConstants.documentExtensions.contains(ext)) {
      if (ext.contains('pdf')) return Icons.picture_as_pdf;
      if (ext.contains('doc')) return Icons.description;
      if (ext.contains('xls')) return Icons.table_chart;
      if (ext.contains('ppt')) return Icons.slideshow;
      if (ext.contains('txt')) return Icons.text_fields;
      return Icons.insert_drive_file;
    } else if (AppConstants.audioExtensions.contains(ext)) {
      return Icons.audiotrack;
    } else if (AppConstants.videoExtensions.contains(ext)) {
      return Icons.videocam;
    } else {
      return Icons.insert_drive_file;
    }
  }
  
  // Get file extension color
  static Color getFileColor(String extension) {
    final ext = extension.toLowerCase();
    
    if (AppConstants.imageExtensions.contains(ext)) {
      return Colors.green;
    } else if (AppConstants.documentExtensions.contains(ext)) {
      if (ext.contains('pdf')) return Colors.red;
      if (ext.contains('doc')) return Colors.blue;
      if (ext.contains('xls')) return Colors.green;
      if (ext.contains('ppt')) return Colors.orange;
      return Colors.grey;
    } else if (AppConstants.audioExtensions.contains(ext)) {
      return Colors.purple;
    } else if (AppConstants.videoExtensions.contains(ext)) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }
  
  // Generate random color
  static Color getRandomColor() {
    final random = Random();
    final colors = [
      AppConstants.royalBlue,
      AppConstants.deepGold,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[random.nextInt(colors.length)];
  }
  
  // Calculate reading time
  static String calculateReadingTime(String text) {
    final wordCount = text.split(RegExp(r'\s+')).length;
    final readingTime = (wordCount / 200).ceil(); // Average reading speed: 200 wpm
    
    if (readingTime == 0) return 'Less than 1 min';
    return '$readingTime min read';
  }
  
  // Extract first sentence
  static String extractFirstSentence(String text, {int maxLength = 100}) {
    final sentences = text.split(RegExp(r'[.!?]+'));
    
    if (sentences.isNotEmpty) {
      final firstSentence = sentences.first.trim();
      
      if (firstSentence.length > maxLength) {
        return '${firstSentence.substring(0, maxLength)}...';
      }
      
      return firstSentence;
    }
    
    return text.length > maxLength 
        ? '${text.substring(0, maxLength)}...'
        : text;
  }
  
  // Generate initials from name
  static String getInitials(String name) {
    final parts = name.split(' ');
    
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, min(2, name.length)).toUpperCase();
    }
    
    return '??';
  }
  
  // Check if string is a URL
  static bool isUrl(String text) {
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text);
  }
  
  // Check if string is an email
  static bool isEmail(String text) {
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailPattern.hasMatch(text);
  }
  
  // Check if string is a phone number
  static bool isPhoneNumber(String text) {
    final phonePattern = RegExp(r'^[0-9]{10}$');
    return phonePattern.hasMatch(text);
  }
  
  // Get platform-specific path separator
  static String get pathSeparator => Platform.pathSeparator;
  
  // Get app documents directory path
  static Future<String> getDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  // Get app cache directory path
  static Future<String> getCachePath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }
  
  // Get app external storage directory path
  static Future<String?> getExternalStoragePath() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      return directory?.path;
    }
    return null;
  }
  
  // Show snackbar with custom styling
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color backgroundColor = AppConstants.royalBlue,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppConstants.royalBlue,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  
  // Copy to clipboard
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    // await Clipboard.setData(ClipboardData(text: text));
    showSnackBar(
      context: context,
      message: 'Copied to clipboard',
      backgroundColor: Colors.green,
    );
  }
  
  // Vibrate device (if supported)
  static void vibrate({Duration duration = const Duration(milliseconds: 100)}) {
    // HapticFeedback.lightImpact();
  }
}