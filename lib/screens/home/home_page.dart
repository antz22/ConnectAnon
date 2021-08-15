import 'dart:io';

import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/screens/chat_rooms/chat_rooms.dart';
import 'package:anonymous_chat/screens/conversations/conversations_screen.dart';
import 'package:anonymous_chat/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.message = ''}) : super(key: key);

  final String message;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _selectedIndex = 0;
  String currentUserId = '';

  List<Widget> tabs = new List.from([]);

  Future<void> _retrieveId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('id')!;
    tabs = [
      ConversationsScreen(currentUserId: currentUserId),
      ChatRoomsScreen(currentUserId: currentUserId),
    ];
  }

  void registerNotification() {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      print('onMessage: $message');
      if (message.notification != null) {
        showNotification(message.notification!);
      }
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .update({'pushToken': token});
    }).catchError((err) {
      CustomSnackbar.buildWarningMessage(
          context, 'Error', err.message.toString());
    });
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.example.anonymous_chat'
          : 'com.example.anonymous_chat_ios_ting',
      'ConnectAnon Chat App',
      'your channel description',
      // playSound: true,
      // enableVibration: true,
      // importance: Importance.max,
      // priority: Priority.high,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    print(remoteNotification);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _retrieveId();
    registerNotification();
    // configLocalNotification();
    if (widget.message != '') {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        CustomSnackbar.buildWarningMessage(context, 'Error', widget.message);
      });
    }
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    // ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new FutureBuilder(
      future: _retrieveId(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: tabs,
            ),
          ),
          bottomNavigationBar: buildBottomNavigationBar(),
        );
      },
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      unselectedIconTheme: IconThemeData(
        color: Color(0xFFBDBDBD),
      ),
      unselectedItemColor: Color(0xFFBDBDBD),
      unselectedLabelStyle: TextStyle(
        fontSize: 12.0,
      ),
      selectedIconTheme: IconThemeData(
        color: kPrimaryColor,
      ),
      selectedItemColor: kPrimaryColor,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12.0,
      ),
      elevation: 10,
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: _selectedIndex == 0
              ? SvgPicture.asset('assets/svgs/chat_selected.svg')
              : SvgPicture.asset('assets/svgs/chat_unselected.svg'),
          label: "Messages",
        ),
        BottomNavigationBarItem(
          icon: _selectedIndex == 1
              ? SvgPicture.asset('assets/svgs/chat_room_selected.svg')
              : SvgPicture.asset('assets/svgs/chat_room_unselected.svg'),
          label: "Chat Rooms",
        ),
      ],
    );
  }
}
