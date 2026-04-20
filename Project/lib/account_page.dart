import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifications.dart';


// Page used to set up notification settings. Will eventually be used to change other settings
// for the app as well and to view your current account preferences and relevent information.
class AccountPage extends StatefulWidget {
  AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  final _firstNameController = TextEditingController(text: 'John'); // Replace with actual data
  final _lastNameController = TextEditingController(text: 'Doe'); // Replace with actual data
  final _usernameController = TextEditingController(text: 'johndoe123'); // Replace with actual data

  bool _isEditingFirstName = false;
  bool _isEditingLastName = false;
  bool _isEditingUsername = false;

  @override
  void initState() {
    super.initState();
    fetchAccountInfo(); // Fetch AccountInfo when the AccountPage is initialized
  }

  Future<void> fetchAccountInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('Account-info')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          setState(() {
            _firstNameController.text = snapshot['firstName'];
            _lastNameController.text = snapshot['lastName'];
            _usernameController.text = snapshot['username'];
          });
        }
      }
    } catch (e) {
      print("Error fetching account info: $e");
    }
  }
// Notification
  final _formKey = GlobalKey<FormState>();

  final _notifications = Notifications();

  //Title: name of the notification (topmost part)
  //Body: full text of the notification
  //Payload: returned to your app upon someone tapping
  String? title = "Tale Tailor";
  String? body = "Reminder to write today!";
  String? payload = "ABCD";

  @override
  Widget build(BuildContext context) {
    // notification timezone initializes the time zone data used by the package.
    // It's usually called once at the beginning of your application to ensure
    // that the necessary time zone data is loaded and available for use.
    tz.initializeTimeZones();
    _notifications.init();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text('Account Page', style: TextStyle(color: Colors.black),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            buildEditableInfoRow(
              label: 'First Name',
              valueController: _firstNameController,
              isEditing: _isEditingFirstName,
              onEditPressed: () {
                setState(() {
                  _isEditingFirstName = !_isEditingFirstName;
                });
              },
            ),
            SizedBox(height: 10,),
            buildEditableInfoRow(
              label: 'Last Name',
              valueController: _lastNameController,
              isEditing: _isEditingLastName,
              onEditPressed: () {
                setState(() {
                  _isEditingLastName = !_isEditingLastName;
                });
              },
            ),
            SizedBox(height: 10,),
            buildEditableInfoRow(
              label: 'Username',
              valueController: _usernameController,
              isEditing: _isEditingUsername,
              onEditPressed: () {
                setState(() {
                  _isEditingUsername = !_isEditingUsername;
                });
              },
            ),
            SizedBox(height: 20,),

            Divider(),
            // Subtitle: Notifications
            SizedBox(height: 20,),
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Buttons: Send Notification and Set Notification
            Row(
              children: [
                ElevatedButton(
                  onPressed:_notificationNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text('Send Notification'),
                ),
                SizedBox(width: 8), // Add spacing between buttons
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for Set Notification button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text('Set Notification'),
                ),
              ],
            ),
            SizedBox(height: 20,),
            // Divider
            Divider(),

            // Additional Subtitles and Content can be added below
          ],
        ),
      ),
    );
  }

  Widget buildEditableInfoRow({
    required String label,
    required TextEditingController valueController,
    required bool isEditing,
    required VoidCallback onEditPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ${valueController.text}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          onPressed: onEditPressed,
        ),
      ],
    );
  }


  // NOTE: remember to make sure notificaitons are turned on for this app
  // when using a virtual device
  // Used to create a notification immidiately
  void _notificationNow() async{
    _notifications.sendNotificationNow(title!,
        body!, payload!);
  }
}