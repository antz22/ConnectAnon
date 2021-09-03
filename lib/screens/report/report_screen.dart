import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/home/home_page.dart';
import 'package:connect_anon/services/api_services.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:connect_anon/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    Key? key,
    required this.currentUserId,
    required this.peerId,
  }) : super(key: key);

  final String? currentUserId;
  final String? peerId;

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<String> items = [
    'Spam',
    'Sexual activity',
    'Hate speech',
    'Bullying or Harassment',
    'Suicide or self-injury',
    'I feel uncomfortable',
    'Other'
  ];

  String? value = 'Spam';

  final reportDescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File a Report')),
      body: Padding(
        padding: EdgeInsets.all(kDefaultPadding),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why are you reporting this user?',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.3 * kDefaultPadding),
              DropdownButton(
                value: value,
                underline: Container(
                  height: 2,
                  color: kPrimaryColor,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    value = newValue;
                  });
                },
                items: items.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 2.0 * kDefaultPadding),
              Text(
                'Describe the situation.',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.2 * kDefaultPadding),
              CustomTextField(
                controller: reportDescriptionController,
                hintText: 'I felt threatened because...',
                textarea: true,
              ),
              SizedBox(height: 2.0 * kDefaultPadding),
              Text('Note: you can file 1 report per hour.'),
              SizedBox(height: 2.0 * kDefaultPadding),
              ElevatedButton(
                onPressed: () async {
                  String response =
                      await context.read<APIServices>().reportUser(
                            widget.currentUserId,
                            widget.peerId,
                            value,
                            reportDescriptionController.text,
                          );

                  if (response == 'Success') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          message:
                              'Your report will be manually reviewed, thank you.',
                          messageStatus: 'Success',
                        ),
                      ),
                    );
                  } else {
                    CustomSnackbar.buildWarningMessage(context, 'Error',
                        'Wait 1 hour before reporting another user.');
                  }
                },
                child: Text('Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
