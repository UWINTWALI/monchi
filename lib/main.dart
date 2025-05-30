import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/onboarding/presentation/welcome_page.dart';
import 'features/auth/presentation/forgot_password_page.dart';
import 'features/auth/presentation/otp_verification_page.dart';
import 'features/auth/presentation/reset_password_page.dart';
import 'features/auth/presentation/reset_success_page.dart';
import 'features/auth/presentation/signup_page.dart';
import 'features/auth/presentation/signin_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/dashboard/presentation/emotion_dashboard_page.dart';
import 'features/profile/presentation/profile_page.dart';
import 'features/settings/presentation/settings_page.dart';
import 'main_navigation.dart';
import 'package:provider/provider.dart';
import 'core/settings/settings_provider.dart';
import 'features/about/about_page.dart';
import 'features/schedule/presentation/schedule_page.dart';
import 'features/fcm_test/presentation/fcm_test_page.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/fcm_helper.dart';

// Handle background messages received when the app is terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background message received: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.initialize();
  await NotificationService.requestPermission();

  // Initialize Firebase Cloud Messaging service
  await FCMHelper.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Mochi AI',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.pink,
              scaffoldBackgroundColor: Colors.white,
              textTheme: settings.getAdjustedTextTheme(
                ThemeData.light().textTheme,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.pink,
                secondary: Colors.pinkAccent,
              ),
              textTheme: settings.getAdjustedTextTheme(
                ThemeData.dark().textTheme,
              ),
            ),
            themeMode: settings.themeMode,
            initialRoute: '/',
            routes: {              '/': (_) => const WelcomePage(),
              '/forgot-password': (_) => const ForgotPasswordPage(),
              '/otp': (_) => const OTPVerificationPage(),
              '/reset-password': (_) => const ResetPasswordPage(),
              '/reset-success': (_) => const ResetSuccessPage(),
              '/log-in': (_) => const SigninPage(),
              '/sign-up': (_) => const SignupPage(),
              '/home': (_) => const HomePage(),
              '/dashboard': (_) => const EmotionDashboardPage(),
              '/main': (_) => const MainNavigation(),
              '/profile': (_) => const ProfilePage(),
              '/settings': (_) => const SettingsPage(),
              '/about': (_) => const AboutPage(),
              '/schedule': (_) => const SchedulePage(),
              '/fcm_test': (_) => const FCMTestPage(),
            },
          );
        },
      ),
    );
  }
}
