import 'package:chattappe/pages/service/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/Sign Up.dart';
import 'pages/chat_pae.dart';
import 'pages/forgot_password.dart';
import 'pages/home.dart';
import 'pages/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUp()
    );
  }
}
