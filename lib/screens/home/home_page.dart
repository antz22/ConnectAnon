import 'package:anonymous_chat/constants/constants.dart';
import 'package:anonymous_chat/screens/home/components/conversation_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 0.9 * kDefaultPadding,
          vertical: 1.5 * kDefaultPadding,
        ),
        child: Column(
          children: [
            Row(
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
            ListView.builder(
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                // final Activity activity = activities[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 0.8 * kDefaultPadding),
                  child: ConversationPreview(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svgs/chat_room.svg'),
          label: "Chat Rooms",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svgs/chat.svg'),
          label: "Messages",
        ),
      ],
    );
  }
}
