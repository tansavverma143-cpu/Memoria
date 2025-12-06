import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/screens/activity_log_screen.dart';
import 'package:memoria/screens/ai_reminders_screen.dart';
import 'package:memoria/screens/auto_categorization_screen.dart';
import 'package:memoria/screens/backup_export_screen.dart';
import 'package:memoria/screens/cookies_policy_screen.dart';
import 'package:memoria/screens/device_binding_screen.dart';
import 'package:memoria/screens/doc_upload_screen.dart';
import 'package:memoria/screens/eula_screen.dart';
import 'package:memoria/screens/home_screen.dart';
import 'package:memoria/screens/import_restore_screen.dart';
import 'package:memoria/screens/item_details_screen.dart';
import 'package:memoria/screens/lifevault_screen.dart';
import 'package:memoria/screens/locked_feature_screen.dart';
import 'package:memoria/screens/login_screen.dart';
import 'package:memoria/screens/manual_reminders_screen.dart';
import 'package:memoria/screens/onboarding_screen.dart';
import 'package:memoria/screens/photo_upload_screen.dart';
import 'package:memoria/screens/privacy_policy_screen.dart';
import 'package:memoria/screens/recently_deleted_screen.dart';
import 'package:memoria/screens/refund_policy_screen.dart';
import 'package:memoria/screens/rewarded_ads_screen.dart';
import 'package:memoria/screens/save_anything_screen.dart';
import 'package:memoria/screens/settings_screen.dart';
import 'package:memoria/screens/signup_screen.dart';
import 'package:memoria/screens/smart_folders_screen.dart';
import 'package:memoria/screens/smart_search_screen.dart';
import 'package:memoria/screens/splash_screen.dart';
import 'package:memoria/screens/subscription_screen.dart';
import 'package:memoria/screens/terms_screen.dart';
import 'package:memoria/screens/voice_to_text_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case RouteConstants.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case RouteConstants.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      
      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case RouteConstants.deviceBinding:
        return MaterialPageRoute(builder: (_) => const DeviceBindingScreen());
      
      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case RouteConstants.saveAnything:
        return MaterialPageRoute(builder: (_) => const SaveAnythingScreen());
      
      case RouteConstants.photoUpload:
        return MaterialPageRoute(builder: (_) => const PhotoUploadScreen());
      
      case RouteConstants.docUpload:
        return MaterialPageRoute(builder: (_) => const DocUploadScreen());
      
      case RouteConstants.voiceToText:
        return MaterialPageRoute(builder: (_) => const VoiceToTextScreen());
      
      case RouteConstants.autoCategorization:
        return MaterialPageRoute(builder: (_) => const AutoCategorizationScreen());
      
      case RouteConstants.itemDetails:
        final item = settings.arguments as SavedItem;
        return MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item));
      
      case RouteConstants.smartSearch:
        return MaterialPageRoute(builder: (_) => const SmartSearchScreen());
      
      case RouteConstants.smartFolders:
        return MaterialPageRoute(builder: (_) => const SmartFoldersScreen());
      
      case RouteConstants.aiReminders:
        return MaterialPageRoute(builder: (_) => const AIRemindersScreen());
      
      case RouteConstants.manualReminders:
        return MaterialPageRoute(builder: (_) => const ManualRemindersScreen());
      
      case RouteConstants.lifeVault:
        return MaterialPageRoute(builder: (_) => const LifeVaultScreen());
      
      case RouteConstants.subscription:
        return MaterialPageRoute(builder: (_) => const SubscriptionScreen());
      
      case RouteConstants.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case RouteConstants.backupExport:
        return MaterialPageRoute(builder: (_) => const BackupExportScreen());
      
      case RouteConstants.importRestore:
        return MaterialPageRoute(builder: (_) => const ImportRestoreScreen());
      
      case RouteConstants.activityLog:
        return MaterialPageRoute(builder: (_) => const ActivityLogScreen());
      
      case RouteConstants.lockedFeature:
        return MaterialPageRoute(builder: (_) => const LockedFeatureScreen());
      
      case RouteConstants.rewardedAds:
        return MaterialPageRoute(builder: (_) => const RewardedAdsScreen());
      
      case RouteConstants.privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      
      case RouteConstants.terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());
      
      case RouteConstants.refundPolicy:
        return MaterialPageRoute(builder: (_) => const RefundPolicyScreen());
      
      case RouteConstants.eula:
        return MaterialPageRoute(builder: (_) => const EulaScreen());
      
      case RouteConstants.cookiesPolicy:
        return MaterialPageRoute(builder: (_) => const CookiesPolicyScreen());
      
      case RouteConstants.recentlyDeleted:
        return MaterialPageRoute(builder: (_) => const RecentlyDeletedScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}