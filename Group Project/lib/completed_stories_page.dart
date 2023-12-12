import 'package:flutter/material.dart';
import 'story class/story.dart'; // Import your Story class


class CompletedStoriesPage extends StatefulWidget {
  Story? individualStory;

  // Constructor accepting a story
  CompletedStoriesPage({this.individualStory});



  @override
  _CompletedStoriesPageState createState() => _CompletedStoriesPageState();
}

class _CompletedStoriesPageState extends State<CompletedStoriesPage> {
  late List<Story> completedStories;

  @override
  void initState() {
    super.initState();
    completedStories = [];
    if (widget.individualStory != null) {
      completedStories.add(widget.individualStory!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: completedStories.length,
        itemBuilder: (context, index) {
          final story = completedStories[index];
          return ListTile(
            title: Text(story.title),
            subtitle: Text('Last edited: ${story.lastEdited}'),
            // Add any other story details you want to display
            onTap: () {
              // Handle tapping on a story to view details or do any action
              // For example:
              // Navigator.of(context).push(MaterialPageRoute(
              //   builder: (context) => StoryDetailsPage(story: story),
              // ));
            },
          );
        },
      ),
    );
  }
}

class CompletedStoryWidget extends StatelessWidget {
  final Story story;
  final VoidCallback onReadPressed;

  const CompletedStoryWidget({Key? key, required this.story, required this.onReadPressed})
      : super(key: key);

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
        trailing: ElevatedButton(
          onPressed: onReadPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Change button color as needed
          ),
          child: const Text(
            'Read',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}