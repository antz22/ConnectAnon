import 'package:connect_anon/screens/account_creation/getting_started.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  void _onIntroEnd(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GettingStartedPage(),
      ),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  Widget _buildSVG(String assetName, [double width = 350]) {
    return SvgPicture.asset('assets/svgs/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: _buildImage('android_launcher.png', 40),
          ),
        ),
      ),
      pages: [
        PageViewModel(
          title: "Create your profile",
          body:
              "Set up an anonymous profile with a custom username and profile picture on a safe platform.",
          image: _buildSVG('create_profile.svg', 250),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Connect anonymously",
          body:
              "In the app, click a button to request a conversation with another peer in the \'Messages\' tab.",
          image: _buildSVG('messaging.svg', 250),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Manage requests",
          body:
              "When another peer requests a conversation with you, have the freedom to accept or decline requests in the \'Requests\' page.",
          image: _buildSVG('manage_requests.svg', 250),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Group Chat Rooms",
          body:
              "Engage in discussions on general topics that are on everyone's mind.",
          image: _buildSVG('group_chat_rooms.svg', 250),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Opt out any time",
          body:
              "File a report, block a user, or archive a conversation by navigating to their profile.",
          image: _buildSVG('opt_out.svg', 250),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.only(bottom: 16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        spacing: EdgeInsets.symmetric(horizontal: 5.0),
      ),
    );
  }
}
