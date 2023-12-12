import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'story class/story.dart';
import 'story_writing_page.dart';
import 'completed_stories_page.dart';

// Ongoing stories page that will house all the stories the user is
// currently working on.
class OngoingPage extends StatefulWidget {
  final String? newStoryTitle;
  int? writingTimeLimit;
  double? waitingTime;

  OngoingPage({Key? key, this.newStoryTitle, this.writingTimeLimit, this.waitingTime});

  @override
  _OngoingPageState createState() => _OngoingPageState();
}

class _OngoingPageState extends State<OngoingPage> {

  final TextEditingController _searchController = TextEditingController();
  final List<Story> stories = [];
  List<Story> filteredStories = [];

  @override
  void initState() {
    super.initState();
    if (widget.newStoryTitle != null) {
      Story newStory = Story(
        widget.newStoryTitle!,
        "",
        widget.writingTimeLimit!,
        widget.waitingTime!,
      );
      stories.add(newStory);
    }
    fetchStoriesFromFirestore(); // Fetch stories from Firestore when the page initializes
  }

  Future<void> fetchStoriesFromFirestore() async {
    String? userUID = FirebaseAuth.instance.currentUser?.uid;

    if (userUID != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('stories')
              .where('userId', isEqualTo: userUID) // Filter stories by user UID
              .get();

      setState(() {
        stories.addAll(snapshot.docs.map((doc) {
          return Story(
            doc['title'],
            doc['lastEdited'],
            doc['writingTimeLimit'],
            doc['waitingTime'],
          );
        }).toList());

        filteredStories = List.from(stories);
      });
    }
  }

  void _searchStories(String query) {
    setState(() {
      filteredStories = stories
          .where((story) =>
              story.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showConfirmationDialog(BuildContext context, Story story) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Finish'),
          content: Text('Are you sure you want to declare this story finished?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _completeStory(story);
              },
              child: Text('Complete'),
            ),
          ],
        );
      },
    );
  }

  void _completeStory(Story story) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompletedStoriesPage(individualStory: story),
      ),
    );

    Navigator.of(context).pushNamed('/completedStory');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchStories,
                    decoration: const InputDecoration(
                      hintText: 'Search Stories',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle button click
                    _searchStories(_searchController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent.shade400,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStories.length,
              itemBuilder: (context, index) {
                final story = filteredStories[index];
                return StorySectionWidget(
                  story: story,
                  onContinuePressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StoryWritingPage(story: story),
                      ),
                    );
                  },
                  onCheckmarkPressed: (Story checkedStory) {
                    _showConfirmationDialog(context, checkedStory);
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StorySectionWidget extends StatelessWidget {
  final Story story;
  final VoidCallback onContinuePressed;
  final ValueChanged<Story> onCheckmarkPressed;

  const StorySectionWidget({
    Key? key,
    required this.story,
    required this.onContinuePressed,
    required this.onCheckmarkPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          story.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(story.lastEdited),
            SizedBox(height: 4),
            Text('Contribution available ${story.waitingTime} hours after last edit'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                onCheckmarkPressed(story);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(30,30),
                padding: EdgeInsets.all(8),
                shape: CircleBorder(),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 8), // Add some space between the checkmark and "Continue" button
            ElevatedButton(
              onPressed: onContinuePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent.shade400,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
