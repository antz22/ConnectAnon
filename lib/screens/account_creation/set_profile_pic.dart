import 'dart:convert';

import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:connect_anon/widgets/photo_credit_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SetProfilePic extends StatefulWidget {
  const SetProfilePic({Key? key}) : super(key: key);

  @override
  _SetProfilePicState createState() => _SetProfilePicState();
}

class _SetProfilePicState extends State<SetProfilePic> {
  List data = new List.from([]);

  String photoUrl = '';

  Future<String> getimages() async {
    // make random photos instead of nature
    String clientId = 'BmuCli3sV_4br-PeAFKMktHlpQvZvS2ig0Tdowitgiw';
    String url =
        'https://api.unsplash.com/photos/random?count=25&client_id=$clientId';
    var getdata = await http.get(Uri.parse(url));
    setState(() {
      data = json.decode(getdata.body);
    });
    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose Profile Picture")),
      body: FutureBuilder(
        future: getimages(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context, data[index]);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 0.03 * MediaQuery.of(context).size.width),
                        child: GestureDetector(
                          onTap: () {
                            _launchUrl(context, data[index]['urls']['regular']);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                            ),
                            child: Image.network(
                              data[index]['urls']['regular'],
                              fit: BoxFit.cover,
                              height: 0.45 * MediaQuery.of(context).size.height,
                              width: 0.94 * MediaQuery.of(context).size.width,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            width:
                                0.03 * MediaQuery.of(context).size.width + 5.0),
                        PhotoCreditWidget(
                            name: data[index]['user']['name'],
                            username: data[index]['user']['username']),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                  ],
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
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
