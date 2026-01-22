import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/set_password_page.dart';
import '../../features/demo/demo_page.dart';
import '../../features/medication/presentation/pages/medication_list_page.dart';
import '../../features/medication/presentation/pages/add_medication_page.dart';
import '../../features/medication/presentation/pages/medication_report_page.dart';
import '../../features/bp_monitoring/presentation/pages/record_bp_page.dart';
import '../../features/bp_monitoring/presentation/pages/bp_history_page.dart';
import '../../features/bp_monitoring/presentation/pages/bp_analysis_page.dart';
import '../../features/bp_monitoring/presentation/pages/bp_emergency_page.dart';
import '../../features/bp_monitoring/data/models/bp_reading_model.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/education/presentation/pages/education_page.dart';
import '../../features/education/presentation/pages/education_detail_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

/// App routes configuration using GoRouter
class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String setPassword = '/set-password';
  static const String demo = '/demo';
  static const String medicationList = '/medication-list';
  static const String addMedication = '/add-medication';
  static const String medicationReport = '/medication-report';
  static const String recordBP = '/record-bp';
  static const String bpHistory = '/bp-history';
  static const String bpAnalysis = '/bp-analysis';
  static const String bpEmergency = '/bp-emergency';
  static const String support = '/support';
  static const String education = '/education';
  static const String educationDetail = '/education-detail';
  static const String dashboard = '/dashboard';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SplashPage(),
        ),
      ),

      // Dashboard Screen
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const DashboardPage(),
        ),
      ),

      // Onboarding Screen
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const OnboardingPage(),
        ),
      ),

      // Login Screen
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginPage(),
        ),
      ),

      // Sign Up Screen
      GoRoute(
        path: signup,
        name: 'signup',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SignUpPage(),
        ),
      ),

      // Set Password Screen
      GoRoute(
        path: setPassword,
        name: 'setPassword',
        pageBuilder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: SetPasswordPage(
              email: extras?['email'],
              fullName: extras?['name'],
              mobile: extras?['mobile'],
              dob: extras?['dob'] as DateTime?,
            ),
          );
        },
      ),

      // Demo Page (for testing shared components)
      GoRoute(
        path: demo,
        name: 'demo',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const DemoPage(),
        ),
      ),

      // Medication List Page
      GoRoute(
        path: medicationList,
        name: 'medicationList',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const MedicationListPage(),
        ),
      ),

      // Add Medication Page
      GoRoute(
        path: addMedication,
        name: 'addMedication',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const AddMedicationPage(),
        ),
      ),

      // Medication Report Page
      GoRoute(
        path: medicationReport,
        name: 'medicationReport',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const MedicationReportPage(),
        ),
      ),

      // Record BP Page
      GoRoute(
        path: recordBP,
        name: 'recordBP',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const RecordBPPage(),
        ),
      ),

      // BP History Page
      GoRoute(
        path: bpHistory,
        name: 'bpHistory',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const BPHistoryPage(),
        ),
      ),

      // BP Analysis Page
      GoRoute(
        path: bpAnalysis,
        name: 'bpAnalysis',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BPAnalysisPage(reading: state.extra as BPReadingModel),
        ),
      ),

      // BP Emergency Page
      GoRoute(
        path: bpEmergency,
        name: 'bpEmergency',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BPEmergencyPage(reading: state.extra as BPReadingModel),
        ),
      ),

      // Support & Help Page
      GoRoute(
        path: support,
        name: 'support',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SupportPage(),
        ),
      ),

      // Education Page
      GoRoute(
        path: education,
        name: 'education',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const EducationPage(),
        ),
      ),

      // Education Detail Page
      GoRoute(
        path: educationDetail,
        name: 'educationDetail',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: EducationDetailPage(type: state.extra as EducationType),
        ),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );

  /// Build page with smooth fade + slide transition.
  /// Gentle animation provides predictable navigation cues for elderly users.
  static Page _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade transition
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        // Subtle slide from right (5% offset)
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
