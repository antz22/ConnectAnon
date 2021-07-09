import 'package:anonymous_chat/constants/constants.dart';
import 'package:flutter/material.dart';

class ConversationPreview extends StatelessWidget {
  const ConversationPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile2.jpg'),
          radius: 28.0,
        ),
        SizedBox(width: 0.9 * kDefaultPadding),
        Container(
          height: 53.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Funny Fox',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'That sounds awesome!',
                style: TextStyle(
                  color: Color(0xFF535353),
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        Text(
          '3m ago',
          style: TextStyle(
            fontSize: 15.0,
            color: Color(0xFF959595),
          ),
        ),
      ],
    );
  }
}
