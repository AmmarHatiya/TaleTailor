import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unsplash_client/unsplash_client.dart';

class CreateNewStory extends StatefulWidget {
  final Function(String) onCreateStory;

  CreateNewStory({required this.onCreateStory});

  @override
  _CreateNewStoryState createState() => _CreateNewStoryState();
}

class _CreateNewStoryState extends State<CreateNewStory> {
  String newStoryTitle = '';
  int writingTimeLimit = 5;
  double waitingTime = 24.0;
  String imageUrl = '';
  bool imageLoaded = false;

  Future<void> createFirestoreStory(String title) async {
    if (title.isNotEmpty) {
      String? userUID = FirebaseAuth.instance.currentUser?.uid; // Get current user's UID

      if (userUID != null) {
        CollectionReference stories =
            FirebaseFirestore.instance.collection('stories');

        // Create a story with the associated user UID
        await stories.add({
          'title': title,
          'lastEdited': "Last edited: Just now",
          'writingTimeLimit': writingTimeLimit,
          'waitingTime': waitingTime,
          'userId': userUID, // Include the user's UID in the story data
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        newStoryTitle = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter Story Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'How much time do you wish to write for each entry to your story?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  DropdownButton<int>(
                    value: writingTimeLimit,
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          writingTimeLimit = value;
                        });
                      }
                    },
                    items: <int>[
                      1,
                      2,
                      3,
                      4,
                      5,
                      10,
                      15,
                      30,
                      45,
                      60
                    ]
                        .map<DropdownMenuItem<int>>(
                          (int value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value minutes'),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'How long do you wish until you are able to make your next entry to your story?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  // My drop down button will go here.
                  DropdownButton<double>(
                    value: waitingTime,
                    onChanged: (double? value) {
                      if (value != null) {
                        setState(() {
                          waitingTime = value;
                        });
                      }
                    },
                    items: <double>[
                      24.0, // once every 24 hours
                      48.0, // once every other day
                      168.0, // once a week (24 * 7)
                      0.0166667,
                      // Add more options as needed
                    ].map<DropdownMenuItem<double>>(
                      (double value) => DropdownMenuItem<double>(
                        value: value,
                        child: Text(
                          value == 0.0166667
                              ? 'Once every minute'
                              : 'Once every ${value ~/ 24} ${value ~/ 24 == 1 ? 'day' : 'days'}',
                        ),
                      ),
                    ).toList(),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      widget.onCreateStory(newStoryTitle);
                      createFirestoreStory(newStoryTitle); // Created story details in Firestore
                      Navigator.of(context).pushNamed('/ongoing');
                    },
                    child: Text('Create Story'),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ElevatedButton(
                        onPressed: () async {
                          final url = await getPhoto();
                          setState(() {
                            imageUrl = url;
                            imageLoaded = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent.shade400,
                        ),
                        child: const Text(
                          'Inspire Me',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Added spacing after the button
                  if (imageLoaded && imageUrl.isNotEmpty)
                    Container(
                      margin: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.deepPurpleAccent.shade400,
                          width: 4,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width *
                          0.8, // 80% of screen width
                      height: MediaQuery.of(context).size.width *
                          0.8, // Square image
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> getPhoto() async {
  // Get a random image, matching the "fantasy world" query

  // Access Unsplash api
  final client = UnsplashClient(
    settings: const ClientSettings(
      credentials: AppCredentials(
        accessKey: 'T-yfUsk_yM_IPrm9MmIVmmPaFyBPe_po60bNOliPipA',
        secretKey: 'U6PVI5XbHfTkhFpQcMZvM6UxVBgqUa86_DLPl5jGPbk',
      ),
    ),
  );

  // HTTP GET REQUEST
  // Get a random image from unsplash client
  final photos =
      await client.photos.random(count: 1, query: 'Fantasy World').goAndGet();

  client.close();
  return photos.first.urls.regular.toString();
}
