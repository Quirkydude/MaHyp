import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/connectivity_service.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notification Service
  await NotificationService().initialize();

  // Initialize Connectivity Monitoring
  await ConnectivityService().initialize();

  // Set preferred orientations (portrait only for elderly users)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MaHypApp()));
}

class MaHypApp extends ConsumerWidget {
  const MaHypApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme setting
    final settings = ref.watch(settingsProvider);
    final theme = settings.darkModeEnabled ? AppTheme.darkTheme : AppTheme.lightTheme;
    
    // Calculate text scale factor from font size setting
    double textScaleFactor = 1.0;
    switch (settings.fontSize) {
      case 'Small':
        textScaleFactor = 0.85;
        break;
      case 'Medium':
        textScaleFactor = 1.0;
        break;
      case 'Large':
        textScaleFactor = 1.15;
        break;
      case 'Extra Large':
        textScaleFactor = 1.3;
        break;
    }

    return MaterialApp.router(
      title: 'MaHyp',
      debugShowCheckedModeBanner: false,

      // Theme - reactive to dark mode setting
      theme: theme,

      // Router
      routerConfig: AppRouter.router,

      // Builder for text scaling
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: child!,
        );
      },
    );
  }
}
