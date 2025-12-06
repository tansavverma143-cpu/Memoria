import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/user_model.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/models/subscription_model.dart';
import 'package:memoria/models/deleted_item_model.dart';
import 'package:memoria/services/subscription_service.dart';

class StorageService {
  static late Box<User> _userBox;
  static late Box<SavedItem> _itemsBox;
  static late Box<Folder> _foldersBox;
  static late Box<Subscription> _subscriptionBox;
  static late Box<UserSettings> _settingsBox;
  static late Box _vaultBox;
  static late Box<DeletedItem> _deletedItemsBox;
  
  static Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
    
    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(SavedItemAdapter());
    Hive.registerAdapter(ItemTypeAdapter());
    Hive.registerAdapter(FolderAdapter());
    Hive.registerAdapter(SubscriptionAdapter());
    Hive.registerAdapter(SubscriptionPlanAdapter());
    Hive.registerAdapter(PurchaseHistoryAdapter());
    Hive.registerAdapter(DeletedItemAdapter());
    
    // Open boxes
    _userBox = await Hive.openBox<User>(AppConstants.userBox);
    _itemsBox = await Hive.openBox<SavedItem>(AppConstants.itemsBox);
    _foldersBox = await Hive.openBox<Folder>('folders');
    _subscriptionBox = await Hive.openBox<Subscription>(AppConstants.subscriptionBox);
    _settingsBox = await Hive.openBox<UserSettings>(AppConstants.settingsBox);
    _vaultBox = await Hive.openBox(AppConstants.vaultBox);
    _deletedItemsBox = await Hive.openBox<DeletedItem>(AppConstants.deletedItemsBox);
  }
  
  // User Operations
  static Future<void> saveUser(User user) async {
    await _userBox.put('current_user', user);
  }
  
  static User? getCurrentUser() {
    return _userBox.get('current_user');
  }
  
  static Future<void> clearUser() async {
    await _userBox.clear();
  }
  
  // Settings Operations
  static Future<void> saveSettings(UserSettings settings) async {
    await _settingsBox.put('user_settings', settings);
  }
  
  static UserSettings getSettings() {
    return _settingsBox.get('user_settings') ?? UserSettings();
  }
  
  // Item Operations
  static Future<void> saveItem(SavedItem item) async {
    await _itemsBox.put(item.id, item);
  }
  
  static SavedItem? getItem(String id) {
    return _itemsBox.get(id);
  }
  
  static List<SavedItem> getAllItems() {
    return _itemsBox.values
        .where((item) => item.deletedAt == null)
        .toList();
  }
  
  static List<SavedItem> getItemsByType(ItemType type) {
    return _itemsBox.values
        .where((item) => item.type == type && item.deletedAt == null)
        .toList();
  }
  
  static List<SavedItem> searchItems(String query) {
    return _itemsBox.values.where((item) {
      if (item.deletedAt != null) return false;
      return item.title.toLowerCase().contains(query.toLowerCase()) ||
             item.content.toLowerCase().contains(query.toLowerCase()) ||
             item.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }
  
  // Soft delete item (move to recently deleted)
  static Future<void> softDeleteItem(String id) async {
    final item = _itemsBox.get(id);
    if (item != null) {
      // Mark as deleted
      item.deletedAt = DateTime.now();
      await _itemsBox.put(id, item);
      
      // Create deleted item entry
      final deletedItem = DeletedItem.fromSavedItem(
        item, 
        _getRetentionDays(),
      );
      
      // Save to deleted items
      await _deletedItemsBox.put(id, deletedItem);
    }
  }
  
  // Restore deleted item
  static Future<void> restoreItem(String id) async {
    final deletedItem = _deletedItemsBox.get(id);
    if (deletedItem != null) {
      // Remove from deleted items
      await _deletedItemsBox.delete(id);
      
      // Restore original item
      final item = deletedItem.item;
      item.deletedAt = null;
      await _itemsBox.put(id, item);
    }
  }
  
  // Permanent delete
  static Future<void> permanentDeleteItem(String id) async {
    await _deletedItemsBox.delete(id);
    await _itemsBox.delete(id);
  }
  
  static Future<void> deleteItem(String id) async {
    await _itemsBox.delete(id);
  }
  
  static int getItemCount() {
    return _itemsBox.values
        .where((item) => item.deletedAt == null)
        .length;
  }
  
  static int getTotalStorageUsed() {
    return _itemsBox.values
        .where((item) => item.deletedAt == null)
        .fold(0, (sum, item) => sum + item.fileSize);
  }
  
  // Folder Operations
  static Future<void> saveFolder(Folder folder) async {
    await _foldersBox.put(folder.id, folder);
  }
  
  static Folder? getFolder(String id) {
    return _foldersBox.get(id);
  }
  
  static List<Folder> getAllFolders() {
    return _foldersBox.values.toList();
  }
  
  static Future<void> deleteFolder(String id) async {
    await _foldersBox.delete(id);
  }
  
  // Subscription Operations
  static Future<void> saveSubscription(Subscription subscription) async {
    await _subscriptionBox.put('current_subscription', subscription);
  }
  
  static Subscription getSubscription() {
    return _subscriptionBox.get('current_subscription') ?? 
           Subscription(deviceId: DeviceService.getDeviceId());
  }
  
  // Vault Operations
  static Future<void> saveToVault(String key, String encryptedData) async {
    await _vaultBox.put(key, encryptedData);
  }
  
  static String? getFromVault(String key) {
    return _vaultBox.get(key);
  }
  
  static Future<void> removeFromVault(String key) async {
    await _vaultBox.delete(key);
  }
  
  static List<String> getAllVaultKeys() {
    return _vaultBox.keys.cast<String>().toList();
  }
  
  // Deleted Items Operations
  static List<DeletedItem> getDeletedItems() {
    return _deletedItemsBox.values.toList();
  }
  
  static int getDeletedItemsCount() {
    return _deletedItemsBox.length;
  }
  
  // Clean up expired deleted items
  static Future<void> cleanupExpiredDeletedItems() async {
    final now = DateTime.now();
    final expiredItems = _deletedItemsBox.values
        .where((item) => item.isExpired)
        .toList();
    
    for (final deletedItem in expiredItems) {
      await permanentDeleteItem(deletedItem.item.id);
    }
  }
  
  // Get retention days based on plan
  static int _getRetentionDays() {
    final subscription = getSubscription();
    
    switch (subscription.plan) {
      case SubscriptionPlan.free:
        return 30;
      case SubscriptionPlan.basic_monthly:
      case SubscriptionPlan.basic_annual:
        return 60;
      case SubscriptionPlan.pro_monthly:
      case SubscriptionPlan.pro_annual:
      case SubscriptionPlan.vault_plus:
        return 365;
      default:
        return 30;
    }
  }
  
  // Backup & Restore
  static Future<void> clearAllData() async {
    await _userBox.clear();
    await _itemsBox.clear();
    await _foldersBox.clear();
    await _subscriptionBox.clear();
    await _settingsBox.clear();
    await _vaultBox.clear();
    await _deletedItemsBox.clear();
  }
  
  static Future<void> close() async {
    await _userBox.close();
    await _itemsBox.close();
    await _foldersBox.close();
    await _subscriptionBox.close();
    await _settingsBox.close();
    await _vaultBox.close();
    await _deletedItemsBox.close();
  }
}