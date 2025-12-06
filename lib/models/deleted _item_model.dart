import 'package:hive/hive.dart';
import 'package:memoria/models/item_model.dart';

part 'deleted_item_model.g.dart';

@HiveType(typeId: 9)
class DeletedItem {
  @HiveField(0)
  final SavedItem item;
  
  @HiveField(1)
  final DateTime deletedAt;
  
  @HiveField(2)
  DateTime permanentDeleteDate;
  
  @HiveField(3)
  bool canRestore;
  
  DeletedItem({
    required this.item,
    required this.deletedAt,
    required this.permanentDeleteDate,
    this.canRestore = true,
  });
  
  factory DeletedItem.fromSavedItem(SavedItem item, int retentionDays) {
    return DeletedItem(
      item: item,
      deletedAt: DateTime.now(),
      permanentDeleteDate: DateTime.now().add(Duration(days: retentionDays)),
    );
  }
  
  int get daysUntilPermanentDelete {
    final now = DateTime.now();
    final difference = permanentDeleteDate.difference(now);
    return difference.inDays;
  }
  
  bool get isExpired {
    return DateTime.now().isAfter(permanentDeleteDate);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'deletedAt': deletedAt.toIso8601String(),
      'permanentDeleteDate': permanentDeleteDate.toIso8601String(),
      'canRestore': canRestore,
    };
  }
  
  factory DeletedItem.fromJson(Map<String, dynamic> json) {
    return DeletedItem(
      item: SavedItem.fromJson(json['item']),
      deletedAt: DateTime.parse(json['deletedAt']),
      permanentDeleteDate: DateTime.parse(json['permanentDeleteDate']),
      canRestore: json['canRestore'],
    );
  }
}