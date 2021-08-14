import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SetProfilePic extends StatefulWidget {
  const SetProfilePic({Key? key}) : super(key: key);

  @override
  _SetProfilePicState createState() => _SetProfilePicState();
}

class _SetProfilePicState extends State<SetProfilePic> {
  List data = new List.from([]);

  Future<String> getimages() async {
    // make random photos instead of nature
    String clientId = 'BmuCli3sV_4br-PeAFKMktHlpQvZvS2ig0Tdowitgiw';
    String url =
        'https://api.unsplash.com/search/photos?per_page=30&client_id=$clientId&query=nature';
    print('hi');
    var getdata = await http.get(Uri.parse(url));
    setState(() {
      var jsondata = json.decode(getdata.body);
      data = jsondata['results'];
    });
    print(data);
    return "Success";
  }

  Future<String> _onTap(String url) async {
    // make this in apiservices
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString('id');

    // if (user != null) {
    FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'photoUrl': url,
    });
    // }
    return 'Success';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wallpaper app")),
      body: FutureBuilder(
        future: getimages(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _onTap(data[index]['urls']['regular']);
                      showDialog(
                          context: context,
                          builder: (context) => Text('Success'));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35.0),
                          topRight: Radius.circular(35.0),
                          bottomLeft: Radius.circular(35.0),
                          bottomRight: Radius.circular(35.0),
                        ),
                        child: Image.network(
                          data[index]['urls']['regular'],
                          fit: BoxFit.cover,
                          height: 500.0,
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
