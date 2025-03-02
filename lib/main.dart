import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:neuro_vision7/pages/welcomePage.dart';
import 'package:neuro_vision7/pages/addPatient.dart'; // Add the new Patient page import
import 'package:neuro_vision7/pages/signUp.dart';
import 'package:neuro_vision7/pages/logIn.dart';
import 'package:neuro_vision7/pages/profile.dart' as info;
import 'package:neuro_vision7/pages/home.dart';
import 'package:neuro_vision7/pages/testMRIImage.dart';
import 'package:neuro_vision7/pages/patientsRecord.dart';

void main() {
  // Initialize FFI for SQLite on Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => Home(),
        '/doctor': (context) => Doctor(),
        '/login': (context) => LogIn(), // Add the login page route
        '/info': (context) => info.InfoPage(
            user: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>),
        '/account': (context) => AccountPage(
            user: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>),
        '/patient': (context) => PatientPage(
            user: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>),
        '/testMRIImage': (context) => TestMRIImage(
            patient: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>),
        '/previousTests': (context) => PreviousTestsPage(),
      },
    );
  }
}
