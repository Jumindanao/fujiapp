import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminChallengeOptionPage.dart';
import 'package:fuji_app/adminpages/AdminChallengesPage.dart';
import 'package:fuji_app/adminpages/AdminCourse.dart';
import 'package:fuji_app/adminpages/AdminLessonPage.dart';

import 'package:fuji_app/adminpages/AdminUnitsPage.dart';
import 'package:fuji_app/pages/CoursePage.dart';
import 'package:fuji_app/pages/DrawingCanvas.dart';
import 'package:fuji_app/pages/EditProfilePage.dart';
import 'package:fuji_app/pages/FinishPage.dart';
import 'package:fuji_app/pages/HomePageWidget.dart';
import 'package:fuji_app/pages/Leaderboardpage.dart';
import 'package:fuji_app/pages/LearnPage.dart';
import 'package:fuji_app/pages/QuizPage.dart';
import 'package:fuji_app/pages/UnitsFetcher.dart';
import 'package:fuji_app/pages/login_page.dart';
import 'package:fuji_app/pages/signup_page.dart';
import 'package:fuji_app/pages/userprofile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://hflpnwzwzdhpwkmxvgqa.supabase.co/",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbHBud3p3emRocHdrbXh2Z3FhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU1NDg2NTMsImV4cCI6MjA0MTEyNDY1M30.r_QH2l4_XO9nn4AUCZTb-kR98wIUSLXcKNPQRBX69I0",
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FUJI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/homepage': (context) => const HomePageWidget(),
        '/LearnPage': (context) => const LearnPage(),
        '/EditProfilePage': (context) => const EditProfilePage(),
        '/Userprofileview': (context) => const UserProfileView(),
        '/CoursePage': (context) => const CoursePage(),
        '/QuizPage': (context) => const QuizPage(),
        '/DrawingCanvas': (context) => const DrawingCanvas(),
        '/Leaderboardpage': (context) => const Leaderboardpage(),
        '/FinishPage': (context) => const FinishPage(),
        // ADMIN Side
        '/AdminCourse': (context) => const AdminCourse(),
        '/AdminLessonPage': (context) => const AdminLessonPage(),
        '/AdminUnitPage': (context) => const AdminUnitsPage(),
        '/AdminChallengesPage': (context) => const AdminChallengesPage(),
        '/AdminChallengeOptionPage': (context) =>
            const AdminChallengeOptionPage(),
        '/fetchertest': (context) => UnitsFetcher(),
      },
    );
  }
}
