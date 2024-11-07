// lib/main.dart
import 'package:app/views/general_forum_screen.dart';
import 'package:app/views/manage_roles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/firebase_options.dart';
import 'views/landing_page.dart';
import 'views/login_screen.dart';
import 'views/signup_screen.dart';
import 'views/home_screen.dart';
import 'views/edit_user_screen.dart';
import 'views/project_form_screen.dart';
import 'views/wallet_screen.dart';
import 'views/buy_digital_currency_screen.dart';
import 'views/manage_roles.dart';             // admin
import 'views/manage_user_screen.dart';       // supervisor
import 'views/statistics_screen.dart';        // analista
import 'views/home_screen_inCharge.dart';     //encargado



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto 1 - Requerimientos de Software',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(), 
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/create-project': (context) => const ProjectFormScreen(),
        '/edit-profile': (context) => const EditUserScreen(),
        '/home-admin': (context) => const ManageRolesScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/buy-digital-currency': (context) => const BuyDigitalCurrencyScreen(),
        '/general-forum': (context) => GeneralForumScreen(),
        '/home-analyst': (context) => StatisticsScreen(),
        '/home-supervisor': (context) => ManageUsersScreen(),
        '/home-inCharge': (context) => HomeScreenInCharge()
      },
    );
  }
}
