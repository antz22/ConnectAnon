import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/profile/profile_screen.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:flutter/material.dart';

class InfoHeader extends StatelessWidget {
  const InfoHeader({
    Key? key,
    required this.title,
    required this.photoUrl,
    required this.id,
    this.atTop = true,
  }) : super(key: key);

  final String title;
  final String photoUrl;
  final String id;
  final bool atTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 0.9 * kDefaultPadding,
        right: 0.9 * kDefaultPadding,
        top: 0.7 * kDefaultPadding,
        bottom: 0.7 * kDefaultPadding,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 5.0,
            color: atTop
                ? Theme.of(context).scaffoldBackgroundColor
                : Colors.grey.shade200,
            offset: Offset(0.0, 5.0),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Row(
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
      ),
    );
  }
}
