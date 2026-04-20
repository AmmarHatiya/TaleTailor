import 'package:flutter/material.dart';

// Displays a single instance of a writing piece
class StoryPiece extends StatelessWidget {
  // final String authorName;
  final String text;

  StoryPiece({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0), // Add margin to the bottom
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Author: $authorName',
            //   style: TextStyle(fontWeight: FontWeight.bold),
            // ),
            Text(text),
          ],
        ),
      ),
    );
  }
}
