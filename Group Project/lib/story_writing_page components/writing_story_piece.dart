import 'package:flutter/material.dart';
import 'dart:async';

// The section where the user actually writes a piece
class WritingStoryPiece extends StatefulWidget {
  final ValueChanged<String> onCommit;
  final VoidCallback onTimerStart;
  final VoidCallback onCommitAction;
  final bool textFieldEnabled;
  final Future<String> Function() getExistingText; // Updated line

  WritingStoryPiece({
    required this.onCommit,
    required this.onTimerStart,
    required this.onCommitAction,
    required this.textFieldEnabled,
    required this.getExistingText, // Updated argument
  });

  @override
  _WritingStoryPieceState createState() => _WritingStoryPieceState();
}


class _WritingStoryPieceState extends State<WritingStoryPiece> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeText();
  }

  void _initializeText() async {
    String initialText = await widget.getExistingText(); // Fetch existing text
    setState(() {
      _textController.text = initialText;
    });
  }

  // late Timer _timer;
  // int _remainingTimeInSeconds = 0;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          enabled: widget.textFieldEnabled,
          onTap: () {
            widget.onTimerStart();
          },
          controller: _textController,
          maxLines: null,
          minLines: 3,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            hintText: 'Write your story piece...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8.0), // Add margin top
          child: ElevatedButton(
            onPressed: () {
              final text = _textController.text;
              if (text.isNotEmpty) {
                widget.onCommit(text);
                _textController.clear();
                widget.onCommitAction();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent.shade400,
            ),
            child: const Text(
                'Commit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
