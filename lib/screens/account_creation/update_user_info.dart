import 'dart:convert';
import 'dart:io' show Platform;

import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/services/firestore_services.dart';
import 'package:connect_anon/widgets/custom_avatar.dart';
import 'package:connect_anon/widgets/custom_popup_dialog.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:connect_anon/widgets/photo_credit_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/src/provider.dart';

class UpdateUserInfoPage extends StatefulWidget {
  const UpdateUserInfoPage({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  _UpdateUserInfoPageState createState() => _UpdateUserInfoPageState();
}

class _UpdateUserInfoPageState extends State<UpdateUserInfoPage> {
  final TextEditingController aliasController = TextEditingController();

  String photoUrl = '';
  String artistName = '';
  String artistUsername = '';
  Map<String, dynamic>? newImage = new Map<String, dynamic>();
  String? value = 'Montgomery High School (NJ)';

  Future<Map<String, dynamic>?> getRandomImage() async {
    String clientId = 'BmuCli3sV_4br-PeAFKMktHlpQvZvS2ig0Tdowitgiw';
    String url = 'https://api.unsplash.com/photos/random?client_id=$clientId';
    var response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);
    return data;
  }

  Future<List<String>> getSchools() async {
    List<String> schools = await context.read<FirestoreServices>().getSchools();
    return schools;
  }

  @override
  void dispose() {
    aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Account Setup'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 11.0,
                          color: Colors.black.withOpacity(0.25),
                          spreadRadius: -2.0,
                        ),
                      ],
                    ),
                    child: CustomAvatar(photoUrl: photoUrl, size: 80.0),
                  ),
                  photoUrl.isEmpty
                      ? const SizedBox.shrink()
                      : Positioned(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                photoUrl = '';
                                artistName = '';
                                artistUsername = '';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: kPrimaryColor,
                              ),
                              child: Icon(
                                Icons.cancel,
                                color: Colors.red[400],
                                size: 30.0,
                              ),
                            ),
                          ),
                          bottom: 5.0,
                          right: 5.0,
                        ),
                ],
              ),
              artistName.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        SizedBox(height: 0.8 * kDefaultPadding),
                        PhotoCreditWidget(
                            name: artistName, username: artistUsername),
                      ],
                    ),
              const SizedBox(height: 1.2 * kDefaultPadding),
              Text('Set optional profile picture using Unsplash images'),
              const SizedBox(height: 0.8 * kDefaultPadding),
              ElevatedButton(
                onPressed: () async {
                  try {
                    newImage = await getRandomImage();
                    if (newImage != null) {
                      setState(() {
                        photoUrl = newImage!['urls']['regular'];
                        artistName = newImage!['user']['name'];
                        artistUsername = newImage!['user']['username'];
                      });
                    }
                  } catch (e) {
                    print(e);
                    CustomSnackbar.buildWarningMessage(
                        context, 'Error', 'Failed to retrieve Unsplash image');
                  }
                },
                child: Text('Random'),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const SizedBox(width: 2 * kDefaultPadding),
              //     ElevatedButton(
              //         onPressed: () async {
              //           newImage = await Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => SetProfilePic(),
              //             ),
              //           );
              //           if (newImage != null) {
              //             CustomSnackbar.buildInfoMessage(
              //                 context,
              //                 'Success',
              //                 'Photo by ' +
              //                     newImage!['user']['name'] +
              //                     ' selected');
              //             setState(() {
              //               photoUrl = newImage!['urls']['regular'];
              //               artistName = newImage!['user']['name'];
              //               artistUsername = newImage!['user']['username'];
              //             });
              //           }
              //         },
              //         child: Text('Choose')),
              //   ],
              // ),
              Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: TextField(
                  controller: aliasController,
                  decoration: InputDecoration(
                    hintText: 'Alias',
                  ),
                ),
              ),
              const SizedBox(height: 0.6 * kDefaultPadding),
              FutureBuilder(
                future: getSchools(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return DropdownButton(
                      value: value,
                      onChanged: (String? newValue) {
                        setState(() {
                          value = newValue;
                        });
                      },
                      items: snapshot.data
                          .map<DropdownMenuItem<String>>((school) =>
                              DropdownMenuItem<String>(
                                  value: school, child: Text(school)))
                          .toList(),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              const SizedBox(height: kDefaultPadding),
              ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic> params = {
                    'controllerText': aliasController.text,
                    'photoUrl': photoUrl,
                    'school': value,
                    'user': widget.user,
                  };
                  String title = 'Confirm';
                  String content =
                      'This action is irreversible and your alias and profile picture are permanent. Continue?';
                  String purpose = 'Update User Info';
                  if (Platform.isAndroid) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          CustomPopupDialog.buildMaterialPopupDialog(
                              context, params, title, content, purpose),
                    );
                  } else {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) =>
                          CustomPopupDialog.buildMaterialPopupDialog(
                              context, params, title, content, purpose),
                    );
                  }
                },
                child: Text('Update user info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
