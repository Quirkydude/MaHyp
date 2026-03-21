import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/set_password_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/demo/demo_page.dart';
import '../../features/medication/presentation/pages/medication_list_page.dart';
import '../../features/medication/presentation/pages/add_medication_page.dart';
import '../../features/medication/presentation/pages/edit_medication_page.dart';
import '../../features/medication/presentation/pages/medication_report_page.dart';
import '../../features/medication/data/models/medication_model.dart' as med_model;
import '../../features/bp_monitoring/presentation/pages/record_bp_page.dart';
import '../../features/bp_monitoring/presentation/pages/bp_history_page.dart';
import '../../features/bp_monitoring/presentation/pages/bp_analysis_page.dart';
import '../../features/bp_monitoring/presentation/pages/bp_emergency_page.dart';
import '../../features/bp_monitoring/data/models/bp_reading_model.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/education/presentation/pages/education_page.dart';
import '../../features/education/presentation/pages/education_detail_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/notification/presentation/pages/notifications_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String setPassword = '/set-password';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
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
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // Routes that don't require authentication
  static const List<String> _publicRoutes = [
    splash,
    onboarding,
    login,
    signup,
    setPassword,
    forgotPassword,
    demo,
  ];

  // Routes accessible while authenticated but not yet verified
  static const List<String> _unverifiedRoutes = [
    emailVerification,
  ];

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: splash,
    debugLogDiagnostics: true,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],

    // Route guard redirect
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final currentPath = state.matchedLocation;

      final isPublicRoute = _publicRoutes.contains(currentPath) ||
          currentPath.startsWith('/edit-medication');
      final isUnverifiedRoute = _unverifiedRoutes.contains(currentPath);
      final isLoggedIn = user != null;
      final isEmailVerified = user?.emailVerified ?? false;

      // Not logged in
      if (!isLoggedIn) {
        // Allow access to public routes
        if (isPublicRoute) return null;
        // Redirect to login for protected routes
        return login;
      }

      // Logged in but email not verified (skip for social logins)
      if (isLoggedIn && !isEmailVerified) {
        // Check if user signed in via email/password (has password provider)
        final isEmailProvider = user.providerData.any(
          (info) => info.providerId == 'password',
        );

        if (isEmailProvider) {
          // Allow verification page and public routes
          if (isUnverifiedRoute || isPublicRoute) return null;
          // Redirect unverified email users to verification
          return emailVerification;
        }
      }

      // Logged in and verified — redirect away from auth screens
      if (isLoggedIn) {
        if (currentPath == login ||
            currentPath == signup ||
            currentPath == setPassword ||
            currentPath == forgotPassword ||
            currentPath == onboarding ||
            currentPath == emailVerification) {
          return dashboard;
        }
      }

      return null;
    },

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

      // Profile Screen
      GoRoute(
        path: profile,
        name: 'profile',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ProfilePage(),
        ),
      ),

      // Edit Profile Screen
      GoRoute(
        path: editProfile,
        name: 'editProfile',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const EditProfilePage(),
        ),
      ),

      // Settings Screen
      GoRoute(
        path: settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SettingsPage(),
        ),
      ),

      // Notifications Screen
      GoRoute(
        path: notifications,
        name: 'notifications',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const NotificationsPage(),
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

      // Forgot Password Screen
      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ForgotPasswordPage(),
        ),
      ),

      // Email Verification Screen
      GoRoute(
        path: emailVerification,
        name: 'emailVerification',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const EmailVerificationPage(),
        ),
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

      // Edit Medication Page
      GoRoute(
        path: '/edit-medication/:id',
        name: 'editMedication',
        pageBuilder: (context, state) {
          final medication = state.extra is med_model.MedicationModel
              ? state.extra as med_model.MedicationModel
              : null;
          if (medication == null) {
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: const MedicationListPage(),
            );
          }
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: EditMedicationPage(medication: medication),
          );
        },
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
        pageBuilder: (context, state) {
          final reading = state.extra is BPReadingModel
              ? state.extra as BPReadingModel
              : null;
          if (reading == null) {
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: const BPHistoryPage(),
            );
          }
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BPAnalysisPage(reading: reading),
          );
        },
      ),

      // BP Emergency Page
      GoRoute(
        path: bpEmergency,
        name: 'bpEmergency',
        pageBuilder: (context, state) {
          final reading = state.extra is BPReadingModel
              ? state.extra as BPReadingModel
              : null;
          if (reading == null) {
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: const BPHistoryPage(),
            );
          }
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BPEmergencyPage(reading: reading),
          );
        },
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
        pageBuilder: (context, state) {
          final type = state.extra is EducationType
              ? state.extra as EducationType
              : null;
          if (type == null) {
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: const EducationPage(),
            );
          }
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: EducationDetailPage(type: type),
          );
        },
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
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }
}
