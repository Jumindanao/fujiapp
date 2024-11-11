import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminChallengeOptionPage.dart';
import 'package:fuji_app/adminpages/AdminChallengesPage.dart';
import 'package:fuji_app/adminpages/AdminCourse.dart';
import 'package:fuji_app/adminpages/AdminLessonPage.dart';

import 'package:fuji_app/adminpages/AdminUnitsPage.dart';
import 'package:fuji_app/adminpages/ChallengeDetailPage.dart';
import 'package:fuji_app/adminpages/CourseDetailPage.dart';
import 'package:fuji_app/adminpages/LessonDetailPage.dart';
import 'package:fuji_app/adminpages/UnitDetailPage.dart';
import 'package:fuji_app/pages/jishoDictionary.dart';
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
import 'package:fuji_app/speech_to_text_recognition/speechToTextRecognition.dart';
import 'package:fuji_app/splashScreen/splash_screen.dart';
import 'package:fuji_app/textrecognition/text_recognition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
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
      initialRoute: '/',
      routes: {
        //splash Screen
        '/': (context) => const SplashScreen(),
        //App Functionalities for the users
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

        //Tools
        '/Dictionary': (context) => JishoDictionary(),
        '/TextRecognition': (context) => const TextRecognition(),
        '/SpeechtoTextRecognition': (context) =>
            const Speechtotextrecognition(),

        // ADMIN Side

        //Course
        '/AdminCourse': (context) => const AdminCourse(),
        '/CourseDetailPage': (context) => CourseDetailPage(),
        //

        //Lesson
        '/AdminLessonPage': (context) => const AdminLessonPage(),
        '/LessonDetailPage': (context) => LessonDetailPage(),
        //

        //Units
        '/AdminUnitPage': (context) => const AdminUnitsPage(),
        '/UnitDetailPage': (context) => UnitDetailPage(),
        //

        //Challenges
        '/AdminChallengesPage': (context) => const AdminChallengesPage(),
        '/ChallengeDetailPage': (context) => const ChallengeDetailPage(),
        //

        //Challenge Option
        '/AdminChallengeOptionPage': (context) =>
            const AdminChallengeOptionPage(),

        '/fetchertest': (context) => UnitsFetcher(),
      },
    );
  }
}
