import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  const CustomAvatar({
    Key? key,
    required this.photoUrl,
    required this.size,
  }) : super(key: key);

  final String photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: photoUrl != ''
          ? NetworkImage(photoUrl)
          : AssetImage('assets/images/default_profile_pic_2.png')
              as ImageProvider,
      radius: size,
    );
  }
}
