class AppConstants {
  // App Information
  static const String appName = 'MEMORIA';
  static const String appVersion = '1.0.0';
  
  // Brand Colors
  static const Color royalBlue = Color(0xFF1F6FEB);
  static const Color deepGold = Color(0xFFD4AF37);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softGrey = Color(0xFFF5F7FA);
  static const Color ultraBlack = Color(0xFF0D1117);
  static const Color darkGrey = Color(0xFF161B22);
  static const Color mediumGrey = Color(0xFF21262D);
  
  // Gradient Colors
  static const List<Color> premiumGradient = [
    Color(0xFF1F6FEB),
    Color(0xFF4A90E2),
    Color(0xFF6BB5FF),
  ];
  
  static const List<Color> goldGradient = [
    Color(0xFFD4AF37),
    Color(0xFFFFD700),
    Color(0xFFFFE55C),
  ];
  
  // Storage Limits
  static const int freePlanSaves = 100;
  static const int basicPlanStorageGB = 10;
  static const int basicPlanStorageBytes = 10 * 1024 * 1024 * 1024; // 10GB in bytes
  
  // Retention Days by Plan
  static const Map<String, int> retentionDays = {
    'free': 30,
    'basic': 60,
    'pro': 365,
    'vault_plus': 365,
  };
  
  // AdMob Test IDs (Replace with real IDs for production)
  static const String admobAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String admobBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String admobInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String admobRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  
  // Razorpay Test Keys (Replace with real keys for production)
  static const String razorpayKeyId = 'rzp_test_dummykey123';
  static const String razorpayKeySecret = 'dummysecret123';
  
  // Subscription Plans
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'free': {
      'name': 'Free',
      'saves': 100,
      'storage': '100MB',
      'price': '0.00',
      'retention_days': 30,
      'features': [
        'Basic Search',
        'Limited AI Tags',
        'Ad Supported',
        'Basic Folders',
        '30-day Trash Retention',
      ],
      'restrictions': [
        'No Smart AI',
        'No Auto Reminders',
        'No LifeVault',
        'No Export',
      ],
    },
    'basic_monthly': {
      'name': 'Basic Monthly',
      'saves': 'Unlimited',
      'storage': '10GB',
      'price': '1.99',
      'currency': 'USD',
      'retention_days': 60,
      'features': [
        'AI Auto-Categorization',
        'AI Tag Generation',
        'Manual Reminders',
        'Smart Folders',
        'No Ads',
        '60-day Trash Retention',
      ],
    },
    'basic_annual': {
      'name': 'Basic Annual',
      'saves': 'Unlimited',
      'storage': '10GB',
      'price': '19.99',
      'currency': 'USD',
      'retention_days': 60,
      'features': [
        'AI Auto-Categorization',
        'AI Tag Generation',
        'Manual Reminders',
        'Smart Folders',
        'No Ads',
        'Save 20%',
        '60-day Trash Retention',
      ],
    },
    'pro_monthly': {
      'name': 'Pro Monthly',
      'saves': 'Unlimited',
      'storage': 'Unlimited',
      'price': '3.99',
      'currency': 'USD',
      'retention_days': 365,
      'features': [
        'AI Auto-Reminders',
        'Advanced Categorization',
        'NLP Smart Search',
        'Auto-detect Documents',
        'Encrypted Export/Import',
        'Smart Folder Automation',
        'No Ads',
        '1-year Trash Retention',
      ],
    },
    'pro_annual': {
      'name': 'Pro Annual',
      'saves': 'Unlimited',
      'storage': 'Unlimited',
      'price': '39.99',
      'currency': 'USD',
      'retention_days': 365,
      'features': [
        'AI Auto-Reminders',
        'Advanced Categorization',
        'NLP Smart Search',
        'Auto-detect Documents',
        'Encrypted Export/Import',
        'Smart Folder Automation',
        'No Ads',
        'Save 20%',
        '1-year Trash Retention',
      ],
    },
    'vault_plus': {
      'name': 'Vault+ Annual',
      'saves': 'Unlimited',
      'storage': 'Unlimited',
      'price': '9.99',
      'currency': 'USD',
      'retention_days': 365,
      'features': [
        'Full LifeVault (AES-256)',
        'PIN + Biometric Vault',
        'Premium AI Memory Search',
        '100% Offline Mode',
        'Permanent No Ads',
        'All Pro Features Included',
        '1-year Trash Retention',
      ],
    },
  };
  
  // Local Currency Conversion Rates (Sample)
  static const Map<String, double> currencyRates = {
    'USD': 1.0,
    'INR': 83.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 150.0,
    'AUD': 1.52,
    'CAD': 1.36,
    'CHF': 0.88,
    'CNY': 7.20,
  };
  
  // Categories for AI Auto-Categorization
  static const List<String> categories = [
    'Bills',
    'Receipts',
    'Study Notes',
    'Tasks',
    'IDs',
    'Certificates',
    'Travel Documents',
    'Medical',
    'Financial',
    'Personal',
    'Work',
    'Education',
    'Shopping',
    'Entertainment',
    'Other',
  ];
  
  // File Types
  static const List<String> imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
  static const List<String> documentExtensions = ['.pdf', '.doc', '.docx', '.txt', '.xls', '.xlsx', '.ppt', '.pptx'];
  static const List<String> audioExtensions = ['.mp3', '.wav', '.m4a', '.aac'];
  static const List<String> videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
  
  // Encryption Constants
  static const String encryptionKey = 'memoria_secure_key_2024';
  static const String vaultKey = 'lifevault_encryption_key';
  
  // Storage Keys
  static const String userBox = 'user_data';
  static const String itemsBox = 'saved_items';
  static const String vaultBox = 'vault_items';
  static const String subscriptionBox = 'subscription_data';
  static const String settingsBox = 'app_settings';
  static const String deletedItemsBox = 'deleted_items';
  
  // Paths
  static const String backupFolder = 'MemoriaBackups';
  static const String exportExtension = '.memoria';
  
  // URLs
  static const String privacyPolicyUrl = 'https://mymemoria.tech/privacy';
  static const String termsUrl = 'https://mymemoria.tech/terms';
  static const String refundPolicyUrl = 'https://mymemoria.tech/refund';
  static const String eulaUrl = 'https://mymemoria.tech/eula';
  static const String cookiesPolicyUrl = 'https://mymemoria.tech/cookies';
}

class RouteConstants {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String deviceBinding = '/device-binding';
  static const String home = '/home';
  static const String saveAnything = '/save-anything';
  static const String photoUpload = '/photo-upload';
  static const String docUpload = '/doc-upload';
  static const String voiceToText = '/voice-to-text';
  static const String autoCategorization = '/auto-categorization';
  static const String itemDetails = '/item-details';
  static const String smartSearch = '/smart-search';
  static const String smartFolders = '/smart-folders';
  static const String aiReminders = '/ai-reminders';
  static const String manualReminders = '/manual-reminders';
  static const String lifeVault = '/life-vault';
  static const String subscription = '/subscription';
  static const String settings = '/settings';
  static const String backupExport = '/backup-export';
  static const String importRestore = '/import-restore';
  static const String activityLog = '/activity-log';
  static const String lockedFeature = '/locked-feature';
  static const String rewardedAds = '/rewarded-ads';
  static const String recentlyDeleted = '/recently-deleted';
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';
  static const String refundPolicy = '/refund-policy';
  static const String eula = '/eula';
  static const String cookiesPolicy = '/cookies-policy';
}