import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kerbros/screens/home.dart';
import 'package:kerbros/screens/loginPage.dart';
import 'package:kerbros/screens/product.dart';
//import 'package:kerbros/screens/productPage.dart';
import 'package:kerbros/screens/register.dart';
import 'package:kerbros/screens/spashScreen.dart';
// import 'package:kerbros/screens/loginPage.dart';
 import 'package:kerbros/screens/loginPage.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyB6w_jeKOFvAEKtcej127B6dfXjMhRV7B4",
    authDomain: 'kerbros-60f96.firebaseapp.com',
    projectId: 'kerbros-60f96',
    storageBucket: 'kerbros-60f96.appspot.com',
    messagingSenderId: '109682896133',
    appId: '1:109682896133:android:08c43645b2e6bbbcc65b6c',

  );

  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreen(),debugShowCheckedModeBanner: false,);
  }
}