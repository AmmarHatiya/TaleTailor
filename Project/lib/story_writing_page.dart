import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:creative_writing_app/story_writing_page components/story_piece.dart';
import 'package:creative_writing_app/story_writing_page components/writing_story_piece.dart';
import 'story class/story.dart';
import 'dart:async';
import 'package:intl/intl.dart';


// Page where user contributes to their story
class StoryWritingPage extends StatefulWidget {
  final Story story;

  const StoryWritingPage({super.key, required this.story});

  @override
  _StoryWritingPageState createState() => _StoryWritingPageState();
}

class _StoryWritingPageState extends State<StoryWritingPage> {
  List<Widget> storyPieces = [];
  late Timer timer;
  int remainingTimeInSeconds = 0;
  bool textFieldEnabled = true;
  // helps make sure startTimer is only called the first time the textfield is tapped
  bool timerStarted = false;

  @override
  void initState() {
    super.initState();
    remainingTimeInSeconds = widget.story.writingTimeLimit * 60;
    checkTime();
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when disposing the page
    super.dispose();
  }

  void startTimer() {
    setState(() {
      // remainingTimeInSeconds = widget.story.writingTimeLimit * 60;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (remainingTimeInSeconds > 0) {
            remainingTimeInSeconds--;
          } else {
            timer.cancel(); // Stop the timer when it reaches 0
            // Perform actions when timer ends (e.g., disable writing)
            textFieldEnabled = false;
          }
        });
      });
    });
  }
  // Updates Firestore for existing text
  void addStoryPiece(String text) {
    setState(() {
      storyPieces.add(StoryPiece(text: text));
        _showSuccessfulCommit();
        widget.story.setText(text);
        updateFirestoreStory(text);
    });
  }

  // Updates Firestore with new story text
  void updateFirestoreStory(String newText) {
    String? userUID = FirebaseAuth.instance.currentUser?.uid;

    if (userUID != null) {
      FirebaseFirestore.instance.collection('stories')
          .where('userId', isEqualTo: userUID)
          .where('title', isEqualTo: widget.story.title)
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.update({'text': newText});
        });
      });
    }
  }

  void _showSuccessfulCommit() {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully Committed'),
          backgroundColor: Colors.green,
          elevation: 5,
          behavior: SnackBarBehavior.floating,
        )
      // SnackBar(content: Text('Successfully Committed')),
    );
  }

  void updateRemainingTime() {
    if (!timerStarted) {
      startTimer();
      timerStarted = true;
    }
  }

  void disableTextField() {
    setState(() {
      remainingTimeInSeconds = 0;
      textFieldEnabled = false;
      widget.story.lastEdited = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
      timeUntilNextSubmission();
    });

  }
  void timeUntilNextSubmission() {
    // Record the current date/time for the next submission
    DateTime currentDateTime = DateTime.now();
    // Use the currentDateTime as needed (e.g., save it to your Story object)
    // For example:
    widget.story.lastCommitDate = currentDateTime;
  }

  void checkTime() {
    DateTime currentDate = DateTime.now();

    if (widget.story.lastCommitDate != null) {
      // Get the difference between the current date/time and last commit date/time
      DateTime lastCommitDate = widget.story.lastCommitDate!;
      Duration timeDifference = currentDate.difference(lastCommitDate);

      print('The time difference is: ${timeDifference}');
      // Check if the timeDifference is not null
      if (timeDifference != null) {
        // Calculate time difference in hours
        // The following will be used for the demo so you dont have to wait an hour to see the changes
        // double timeDifferenceInHours = timeDifference.inMinutes.toDouble();
        double timeDifferenceInHours = timeDifference.inHours.toDouble();
        // print('The time difference in minutes is : ${timeDifferenceInHours}');
        print('The time difference in hours is : ${timeDifferenceInHours}');
        // Compare the time difference with waitingTime
        if (timeDifferenceInHours >= widget.story.waitingTime) {
          print('Enough time has passed since the last commit.');
        } else {
          print('Not enough time has passed since the last commit.');
        }
      } else {
        print('No last commit date found.');
      }
    }
  }

  // Builds the title, information and the list of contributions for the story
  @override
  Widget build(BuildContext context) {
    String _formatTime(int seconds) {
      Duration duration = Duration(seconds: seconds);
      return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent.shade400,
        title: Text('Writing - ${widget.story.title}'),
      ),
      body: SingleChildScrollView( // Wrap the entire content with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with the title of the story
              Text(
                widget.story.title,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // Last Edited
              Text(
                'Last Entry: ${widget.story.lastEdited}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Created
              Text(
                'Created: ${widget.story.createdDate}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Writing time limit: ${widget.story.writingTimeLimit}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Time Remaining: ${_formatTime(remainingTimeInSeconds)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: remainingTimeInSeconds <= 30 ? Colors.red : Colors.black,
                ),
              ),
              // Contributors
              Container(
                padding: const EdgeInsets.only(bottom: 16.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 2, // Increased height
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...storyPieces,
                    WritingStoryPiece(
                      onCommit: addStoryPiece,
                      onTimerStart: updateRemainingTime,
                      onCommitAction: disableTextField,
                      textFieldEnabled: textFieldEnabled,
                      getExistingText: getExistingText, // Pass the function here
                    ),
                    ],
                  ),
                ),
              SizedBox(height: 20,),
              Text('The current story.lastCommitDate is: ${widget.story.lastCommitDate}'),
              Container(
                margin: EdgeInsets.only(top: 8.0), // Add margin top
                child: ElevatedButton(
                  onPressed: () {
                    DateTime currentDate = DateTime.now();

                    if (widget.story.lastCommitDate != null) {
                      // Get the difference between the current date/time and last commit date/time
                      DateTime lastCommitDate = widget.story.lastCommitDate!;
                      Duration timeDifference = currentDate.difference(lastCommitDate);

                      print('The time difference is: ${timeDifference}');
                      // Check if the timeDifference is not null
                      if (timeDifference != null) {
                        // Calculate time difference in hours
                        double timeDifferenceInHours = timeDifference.inMinutes.toDouble();
                        print('The time difference in minutes is : ${timeDifferenceInHours}');
                        // Compare the time difference with waitingTime
                        if (timeDifferenceInHours >= widget.story.waitingTime) {
                          print('Enough time has passed since the last commit.');
                        } else {
                          print('Not enough time has passed since the last commit.');
                        }
                      } else {
                        print('No last commit date found.');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent.shade400,
                  ),
                  child: const Text(
                      'Check time if time passed has been enough',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<String> getExistingText() async {
    String existingText = await widget.story.getText();
    return existingText;
  }
}
