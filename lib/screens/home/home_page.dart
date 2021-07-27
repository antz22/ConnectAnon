import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/screens/chat/chat_screen.dart';
import 'package:anonymous_chat/screens/home/components/conversation_preview.dart';
import 'package:anonymous_chat/services/api_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.currentUserId}) : super(key: key);

  final String currentUserId;

  @override
  _HomePageState createState() => _HomePageState(currentUserId: currentUserId);
}

class _HomePageState extends State<HomePage> {
  _HomePageState({required this.currentUserId});

  final String currentUserId;

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

  Future<Map<String, String>> _retrievePeerData(group) async {
    Map<String, String> peerData =
        await context.read<APIServices>().getPeerData(group);
    return peerData;
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
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(currentUserId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  List groups = data['groups'];
                  List chattedWith = data['chattedWith'];
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: groups.length,
                        itemBuilder: (BuildContext context, int index) {
                          return FutureBuilder(
                            future: _retrievePeerData(groups[index]),
                            builder: (BuildContext context,
                                AsyncSnapshot<Map<String, String>> snapshot) {
                              if (snapshot.hasData) {
                                String groupChatId = groups[index];
                                String currentUserId =
                                    snapshot.data!['currentUserId']!;
                                String peerId = snapshot.data!['peerId']!;
                                String peerName = snapshot.data!['peerName']!;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          groupChatId: groupChatId,
                                          currentUserId: currentUserId,
                                          peerId: peerId,
                                          peerName: peerName,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      bottom: 0.8 * kDefaultPadding,
                                      left: 0.9 * kDefaultPadding,
                                      right: 0.9 * kDefaultPadding,
                                    ),
                                    child: ConversationPreview(
                                      groupChatId: groupChatId,
                                      currentUserId: currentUserId,
                                      peerId: peerId,
                                      peerName: peerName,
                                    ),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          context
                              .read<APIServices>()
                              .createGroup(currentUserId, chattedWith);
                        },
                        child: Text('Connect to anonymous peer'),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  );
                }
              },
            ),
          ),
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
