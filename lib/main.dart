import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/landing_page/landing_page.dart';
import 'package:connect_anon/services/authentication.dart';
import 'package:connect_anon/services/firestore_services.dart';
import 'package:connect_anon/services/user_provider.dart';
import 'package:connect_anon/services/volunteer_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
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
        Provider<VolunteerServices>(create: (_) => VolunteerServices()),
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
            final userProvider =
                Provider.of<UserProvider>(context, listen: false);
            if (userProvider.alias != null && userProvider.alias != '') {
              return HomePage();
            } else {
              return LandingPage();
            }
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
