import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Story {
  final String title;
  String lastEdited;
  final String createdDate;
  final int writingTimeLimit;
  int remainingWritingTime;
  final double waitingTime;
  DateTime? lastCommitDate;

  Story(
      this.title,
      this.lastEdited,
      this.writingTimeLimit,
      this.waitingTime,
      )   : createdDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        remainingWritingTime = writingTimeLimit * 60;
  String _text = '';

  void setText(String newText) {
    _text = newText;
  }

  Future<String> getText() async {
    String? userUID = FirebaseAuth.instance.currentUser?.uid;
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('stories')
        .where('userId', isEqualTo: userUID)
        .where('title', isEqualTo: title)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.get('text') ?? '';
    } else {
      return '';
    }
  }

  // Method to start the writing timer
  void startWritingTimer() {
    remainingWritingTime = writingTimeLimit * 60;
    // Start a countdown timer
    // You can use a Timer or another mechanism to decrement `remainingWritingTime` periodically
    // For instance, you can use a Timer.periodic and update `remainingWritingTime` every second
  }

  // Method to check if the writing time has expired
  bool isWritingTimeExpired() {
    return remainingWritingTime <= 0;
  }
}
