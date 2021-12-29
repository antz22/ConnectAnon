import 'package:connect_anon/constants/constants.dart';
import 'package:connect_anon/screens/home/home_page.dart';
import 'package:connect_anon/services/firestore_services.dart';
import 'package:connect_anon/services/volunteer_services.dart';
import 'package:connect_anon/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeVolunteerStatus extends StatefulWidget {
  const ChangeVolunteerStatus({
    Key? key,
    required this.volunteerId,
    required this.isAccepting,
  }) : super(key: key);

  final String volunteerId;
  final bool isAccepting;

  @override
  _ChangeVolunteerStatusState createState() => _ChangeVolunteerStatusState();
}

class _ChangeVolunteerStatusState extends State<ChangeVolunteerStatus> {
  final List<String> items = [
    'Accepting',
    'Not Accepting',
  ];

  String? value = 'Accepting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change request status')),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.isAccepting
                ? Text('You are currently accepting requests.')
                : Text('You are currently NOT accepting requests.'),
            const SizedBox(height: 2.5 * kDefaultPadding),
            Text(
              'Change your status to accept peer requests (accepting) or to mark yourself as busy (not accepting).',
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
            const SizedBox(height: 2.5 * kDefaultPadding),
            Text(
              'Request Status:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            const SizedBox(height: 2.5 * kDefaultPadding),
            Text(
              'Accepting requests: allow peers to request you anonymously, having priority to get requests',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            const SizedBox(height: 1.5 * kDefaultPadding),
            Text(
              'Not accepting requests: mark yourself as not accepting requests, having lower priority for getting requests (still might have some requests)',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            const SizedBox(height: 2.5 * kDefaultPadding),
            ElevatedButton(
              onPressed: () async {
                String response = await context
                    .read<VolunteerServices>()
                    .changeRequestStatus(
                        widget.volunteerId, value!, widget.isAccepting);
                if (response == 'Success') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                            message: 'Status changed successfully',
                            messageStatus: 'Success')),
                  );
                } else {
                  CustomSnackbar.buildWarningMessage(
                      context, 'Error', response);
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
