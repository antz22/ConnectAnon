import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/screens/chat/chat_screen.dart';
import 'package:anonymous_chat/screens/home/components/conversation_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  int _limit = 10;
  int _limitIncrement = 10;
  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();

  scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              left: 0.9 * kDefaultPadding,
              right: 0.9 * kDefaultPadding,
              top: 1.5 * kDefaultPadding,
              bottom: 0.4 * kDefaultPadding,
            ),
            child: Row(
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/profile1.jpg'),
                  radius: 25.0,
                ),
              ],
            ),
          ),
          Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(currentUserId)
                      .snapshots(),
                  // .collection('Users')
                  // .limit(_limit)
                  // .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: 3,
                        itemBuilder: (BuildContext context, int index) {
                          // final Activity activity = activities[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        doc: snapshot.data?.docs[index])),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: 0.8 * kDefaultPadding,
                                left: 0.9 * kDefaultPadding,
                                right: 0.9 * kDefaultPadding,
                              ),
                              child: ConversationPreview(
                                  doc: snapshot.data?.docs[index]),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        ),
                      );
                    }
                  }))
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
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
              ? SvgPicture.asset('assets/svgs/chat_room_selected.svg')
              : SvgPicture.asset('assets/svgs/chat_room_unselected.svg'),
          label: "Chat Rooms",
        ),
        BottomNavigationBarItem(
          icon: _selectedIndex == 1
              ? SvgPicture.asset('assets/svgs/chat_selected.svg')
              : SvgPicture.asset('assets/svgs/chat_unselected.svg'),
          label: "Messages",
        ),
      ],
    );
  }
}
