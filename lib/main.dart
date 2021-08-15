import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/screens/account_creation/update_user_info.dart';
import 'package:anonymous_chat/screens/landing_page/landing_page.dart';
import 'package:anonymous_chat/services/api_services.dart';
import 'package:anonymous_chat/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/home/home_page.dart';
import 'screens/sign_in/sign_in_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  // statusBarColor: Colors.transparent,
  // statusBarBrightness: Brightness.dark,
  // ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance)),
        Provider<APIServices>(create: (_) => APIServices()),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Anonymous Chat App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: customSwatch,
        ),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User?>(context, listen: true);

    if (firebaseUser != null) {
      return HomePage();
    } else {
      return LandingPage();
    }
    // return LandingPage();
    // return UpdateUserInfoPage(user: firebaseUser!);
  }
}
