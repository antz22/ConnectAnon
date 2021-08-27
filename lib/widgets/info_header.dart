import 'package:connect_anon/screens/profile/profile_screen.dart';
import 'package:connect_anon/screens/set_profile_pic/set_profile_pic.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';

class InfoHeader extends StatelessWidget {
  const InfoHeader({
    Key? key,
    required this.title,
    required this.photoUrl,
    required this.id,
  }) : super(key: key);

  final String title;
  final String photoUrl;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(isMe: true, id: id),
              ),
            );
          },
          child: CustomAvatar(photoUrl: photoUrl, size: 25.0),
        ),
      ],
    );
  }
}
