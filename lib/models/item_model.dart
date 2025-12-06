import 'package:hive/hive.dart';

part 'item_model.g.dart';

@HiveType(typeId: 3)
enum ItemType {
  @HiveField(0)
  text,
  
  @HiveField(1)
  photo,
  
  @HiveField(2)
  document,
  
  @HiveField(3)
  voice,
  
  @HiveField(4)
  link,
  
  @HiveField(5)
  screenshot,
  
  @HiveField(6)
  bill,
  
  @HiveField(7)
  receipt,
  
  @HiveField(8)
  id,
  
  @HiveField(9)
  certificate,
  
  @HiveField(10)
  note,
  
  @HiveField(11)
  task,
}

@HiveType(typeId: 4)
class SavedItem {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final ItemType type;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  String content;
  
  @HiveField(4)
  final String? filePath;
  
  @HiveField(5)
  final String? fileExtension;
  
  @HiveField(6)
  final int fileSize;
  
  @HiveField(7)
  List<String> tags;
  
  @HiveField(8)
  String? detectedCategory;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  DateTime updatedAt;
  
  @HiveField(11)
  DateTime? reminderDate;
  
  @HiveField(12)
  bool isEncrypted;
  
  @HiveField(13)
  bool isVaultItem;
  
  @HiveField(14)
  String? folderId;
  
  @HiveField(15)
  Map<String, dynamic>? metadata;
  
  @HiveField(16)
  String? ocrText;
  
  @HiveField(17)
  String? aiSummary;
  
  @HiveField(18)
  DateTime? deletedAt;
  
  @HiveField(19)
  bool isPermanentlyDeleted;
  
  SavedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.filePath,
    this.fileExtension,
    required this.fileSize,
    this.tags = const [],
    this.detectedCategory,
    required this.createdAt,
    required this.updatedAt,
    this.reminderDate,
    this.isEncrypted = false,
    this.isVaultItem = false,
    this.folderId,
    this.metadata,
    this.ocrText,
    this.aiSummary,
    this.deletedAt,
    this.isPermanentlyDeleted = false,
  });
  
  factory SavedItem.create({
    required ItemType type,
    required String title,
    required String content,
    String? filePath,
    String? fileExtension,
    int? fileSize,
  }) {
    final now = DateTime.now();
    return SavedItem(
      id: 'item_${now.millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      title: title,
      content: content,
      filePath: filePath,
      fileExtension: fileExtension,
      fileSize: fileSize ?? 0,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'],
      type: ItemType.values.firstWhere((e) => e.toString() == json['type']),
      title: json['title'],
      content: json['content'],
      filePath: json['filePath'],
      fileExtension: json['fileExtension'],
      fileSize: json['fileSize'],
      tags: List<String>.from(json['tags']),
      detectedCategory: json['detectedCategory'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      reminderDate: json['reminderDate'] != null ? DateTime.parse(json['reminderDate']) : null,
      isEncrypted: json['isEncrypted'],
      isVaultItem: json['isVaultItem'],
      folderId: json['folderId'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      ocrText: json['ocrText'],
      aiSummary: json['aiSummary'],
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      isPermanentlyDeleted: json['isPermanentlyDeleted'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'content': content,
      'filePath': filePath,
      'fileExtension': fileExtension,
      'fileSize': fileSize,
      'tags': tags,
      'detectedCategory': detectedCategory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reminderDate': reminderDate?.toIso8601String(),
      'isEncrypted': isEncrypted,
      'isVaultItem': isVaultItem,
      'folderId': folderId,
      'metadata': metadata,
      'ocrText': ocrText,
      'aiSummary': aiSummary,
      'deletedAt': deletedAt?.toIso8601String(),
      'isPermanentlyDeleted': isPermanentlyDeleted,
    };
  }
}

@HiveType(typeId: 5)
class Folder {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final String? icon;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  DateTime updatedAt;
  
  @HiveField(6)
  final String? color;
  
  @HiveField(7)
  bool isSmartFolder;
  
  @HiveField(8)
  Map<String, dynamic>? smartRules;
  
  @HiveField(9)
  int itemCount;
  
  Folder({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.color,
    this.isSmartFolder = false,
    this.smartRules,
    this.itemCount = 0,
  });
  
  factory Folder.create({
    required String name,
    String? description,
    String? icon,
    String? color,
    bool isSmart = false,
  }) {
    final now = DateTime.now();
    return Folder(
      id: 'folder_${now.millisecondsSinceEpoch}',
      name: name,
      description: description,
      icon: icon,
      createdAt: now,
      updatedAt: now,
      color: color,
      isSmartFolder: isSmart,
      itemCount: 0,
    );
  }
}