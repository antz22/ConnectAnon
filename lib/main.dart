import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/account_creation/update_user_info.dart';
import 'package:connect_anon/screens/landing_page/landing_page.dart';
import 'package:connect_anon/services/authentication.dart';
import 'package:connect_anon/services/firestore_services.dart';
import 'package:connect_anon/services/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  //   statusBarBrightness: Brightness.dark,
  // ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
        Provider<FirestoreServices>(create: (_) => FirestoreServices()),
        Provider<UserProvider>(create: (_) => UserProvider()),
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
      return FutureBuilder(
        future: initUser(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
            // return UpdateUserInfoPage(user: firebaseUser);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return LandingPage();
    }
  }

  Future<bool> initUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Provider.of<UserProvider>(context, listen: false).initUser(prefs);
    return true;
  }
}
