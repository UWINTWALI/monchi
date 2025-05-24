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
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
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
            routes: {
              '/': (_) => const WelcomePage(),
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
            },
          );
        },
      ),
    );
  }
}
