import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:memoria/constants/constants.dart';

class EncryptionService {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static late Encrypter _encrypter;
  static late IV _iv;
  
  static Future<void> init() async {
    // Get or generate encryption key
    String? keyString = await _secureStorage.read(key: 'encryption_key');
    
    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      keyString = key.base64;
      await _secureStorage.write(key: 'encryption_key', value: keyString);
    }
    
    final key = Key.fromBase64(keyString);
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    
    // Get or generate IV
    String? ivString = await _secureStorage.read(key: 'encryption_iv');
    
    if (ivString == null) {
      final iv = IV.fromSecureRandom(16);
      ivString = iv.base64;
      await _secureStorage.write(key: 'encryption_iv', value: ivString);
    }
    
    _iv = IV.fromBase64(ivString);
  }
  
  static String encryptString(String plainText) {
    if (plainText.isEmpty) return '';
    
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }
  
  static String decryptString(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      return decrypted;
    } catch (e) {
      return '';
    }
  }
  
  static Uint8List encryptBytes(Uint8List data) {
    final encrypted = _encrypter.encryptBytes(data, iv: _iv);
    return encrypted.bytes;
  }
  
  static Uint8List decryptBytes(Uint8List encryptedData) {
    final encrypted = Encrypted(encryptedData);
    final decrypted = _encrypter.decryptBytes(encrypted, iv: _iv);
    return decrypted;
  }
  
  static String encryptVaultData(String data, String vaultKey) {
    final key = Key.fromUtf8(vaultKey.padRight(32));
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }
  
  static String decryptVaultData(String encryptedData, String vaultKey) {
    try {
      final key = Key.fromUtf8(vaultKey.padRight(32));
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final encrypted = Encrypted.fromBase64(encryptedData);
      final decrypted = encrypter.decrypt(encrypted, iv: _iv);
      return decrypted;
    } catch (e) {
      return '';
    }
  }
  
  static Future<String> generateHash(String data) async {
    final bytes = utf8.encode(data + AppConstants.encryptionKey);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static String generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    final data = '$timestamp$random${AppConstants.appName}';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
  
  static String generateItemId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return 'item_${timestamp}_$random';
  }
}