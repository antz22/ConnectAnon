import 'package:connect_anon/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatRoomsHeader extends StatelessWidget {
  const ChatRoomsHeader({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(45.0),
              bottomRight: Radius.circular(45.0),
            ),
          ),
          height: 0.32 * MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: kDefaultPadding),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(
                      width: 0.29 * MediaQuery.of(context).size.width -
                          kDefaultPadding),
                ],
              ),
              SvgPicture.asset(
                'assets/svgs/chat_room.svg',
                height: 80.0,
                color: Colors.white,
              ),
              SizedBox(height: kDefaultPadding),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 25.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
