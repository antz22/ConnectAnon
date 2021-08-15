import 'package:anonymous_chat/widgets/custom_snackbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhotoCreditWidget extends StatelessWidget {
  const PhotoCreditWidget({
    Key? key,
    required this.name,
    required this.username,
  }) : super(key: key);

  final String name;
  final String username;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Photo by ',
        style: TextStyle(color: Colors.grey.shade600),
        children: [
          TextSpan(
            text: name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  _launchUrl(context, 'https://unsplash.com/@' + username),
          ),
          TextSpan(
            text: ' on ',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          TextSpan(
            text: 'Unsplash',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchUrl(context, 'https://unsplash.com'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url + '?utm_source=ConnectAnon&utm_medium=referral');
    } else {
      CustomSnackbar.buildWarningMessage(
          context, 'Error', 'Could not navigate to url');
    }
  }
}
