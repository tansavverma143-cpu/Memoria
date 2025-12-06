import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/providers/app_provider.dart';
import 'package:memoria/providers/subscription_provider.dart';
import 'package:memoria/providers/user_provider.dart';
import 'package:memoria/routes.dart';
import 'package:memoria/services/encryption_service.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Keep splash screen visible during initialization
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  
  // Initialize services
  await StorageService.init();
  await EncryptionService.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  
  runApp(const MemoriaApp());
}

class MemoriaApp extends StatelessWidget {
  const MemoriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            title: 'MEMORIA',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: RouteConstants.splash,
            onGenerateRoute: AppRoutes.generateRoute,
            navigatorKey: NavigationService.navigatorKey,
          );
        },
      ),
    );
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}