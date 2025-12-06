import 'import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String? phone;
  
  @HiveField(3)
  final String deviceId;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  DateTime? lastLogin;
  
  @HiveField(6)
  final String? profileImage;
  
  @HiveField(7)
  String? displayName;
  
  User({
    required this.id,
    required this.email,
    this.phone,
    required this.deviceId,
    required this.createdAt,
    this.lastLogin,
    this.profileImage,
    this.displayName,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      deviceId: json['deviceId'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      profileImage: json['profileImage'],
      displayName: json['displayName'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'deviceId': deviceId,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'profileImage': profileImage,
      'displayName': displayName,
    };
  }
  
  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? deviceId,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? profileImage,
    String? displayName,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      profileImage: profileImage ?? this.profileImage,
      displayName: displayName ?? this.displayName,
    );
  }
}

@HiveType(typeId: 2)
class UserSettings {
  @HiveField(0)
  bool isDarkMode;
  
  @HiveField(1)
  bool biometricEnabled;
  
  @HiveField(2)
  bool autoBackup;
  
  @HiveField(3)
  bool showTips;
  
  @HiveField(4)
  String language;
  
  @HiveField(5)
  int backupFrequency;
  
  @HiveField(6)
  DateTime? lastBackup;
  
  UserSettings({
    this.isDarkMode = true,
    this.biometricEnabled = false,
    this.autoBackup = false,
    this.showTips = true,
    this.language = 'en',
    this.backupFrequency = 7,
    this.lastBackup,
  });
  
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      isDarkMode: json['isDarkMode'],
      biometricEnabled: json['biometricEnabled'],
      autoBackup: json['autoBackup'],
      showTips: json['showTips'],
      language: json['language'],
      backupFrequency: json['backupFrequency'],
      lastBackup: json['lastBackup'] != null ? DateTime.parse(json['lastBackup']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'biometricEnabled': biometricEnabled,
      'autoBackup': autoBackup,
      'showTips': showTips,
      'language': language,
      'backupFrequency': backupFrequency,
      'lastBackup': lastBackup?.toIso8601String(),
    };
  }
}