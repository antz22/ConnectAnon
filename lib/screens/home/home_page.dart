import 'dart:io';

import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/chat_rooms/chat_rooms.dart';
import 'package:connect_anon/screens/conversations/conversations_screen.dart';
import 'package:connect_anon/screens/requests/requests_screen.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    this.message = '',
    this.messageStatus = '',
  }) : super(key: key);

  final String message;
  final String messageStatus;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _selectedIndex = 0;
  String currentUserId = '';
  String? status = '';
  String? photoUrl = '';

  List<Widget> tabs = new List.from([]);

  Future<void> _retrieveId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = await prefs.getString('id')!;
    status = await prefs.getString('status');
    photoUrl = await prefs.getString('photoUrl');
    if (status == 'Chat Buddy') {
      tabs = [
        ConversationsScreen(currentUserId: currentUserId, status: status),
        RequestsScreen(currentUserId: currentUserId, photoUrl: photoUrl),
        ChatRoomsScreen(currentUserId: currentUserId),
      ];
    } else {
      tabs = [
        ConversationsScreen(currentUserId: currentUserId, status: status),
        ChatRoomsScreen(currentUserId: currentUserId),
      ];
    }
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
          ? 'com.antz.connect_anon'
          : 'com.antz.connect_anon_ios_ting',
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
      if (widget.messageStatus == '') {
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          CustomSnackbar.buildWarningMessage(context, 'Error', widget.message);
        });
      } else {
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          CustomSnackbar.buildInfoMessage(context, 'Success', widget.message);
        });
      }
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
    List<BottomNavigationBarItem> items = status == 'Chat Buddy'
        ? [
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/svgs/chat.svg',
                  color: _selectedIndex == 0
                      ? kPrimaryColor
                      : Colors.grey.shade400),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/svgs/request.svg',
                color:
                    _selectedIndex == 1 ? kPrimaryColor : Colors.grey.shade400,
              ),
              label: "Requests",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/svgs/chat_room.svg',
                color:
                    _selectedIndex == 2 ? kPrimaryColor : Colors.grey.shade400,
              ),
              label: "Chat Rooms",
            ),
          ]
        : [
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/svgs/chat.svg',
                  color: _selectedIndex == 0
                      ? kPrimaryColor
                      : Colors.grey.shade400),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/svgs/chat_room.svg',
                color:
                    _selectedIndex == 1 ? kPrimaryColor : Colors.grey.shade400,
              ),
              label: "Chat Rooms",
            ),
          ];
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
      items: items,
    );
  }
}
