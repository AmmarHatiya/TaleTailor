// Mobile Devices Group Project
// NOTE: CHATGPT was used throughout the development of this project

import 'package:creative_writing_app/create_new_story.dart';
import 'package:creative_writing_app/statistics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:creative_writing_app/sign%20up%20&%20login/SignUp.dart';
import 'package:creative_writing_app/sign%20up%20&%20login/login.dart';
import 'package:creative_writing_app/ongoing_story_page.dart';
import 'package:creative_writing_app/home_page.dart';
import 'package:creative_writing_app/completed_stories_page.dart';
import 'commonScaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    runApp(const MyApp());
  } catch (e) {
    print("Firebase initialization error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            final Map<String, Widget> pages = {
              '/login': LoginScreen(),
              '/signup': SignUpScreen(),
              '/home':
                  HomePage(), //used to be MyHomePage() may need to change back
              '/ongoing': OngoingPage(),
              '/createStory': CreateNewStory(
                onCreateStory: (title) {
                  // Handle the creation of the story here if needed
                  print('Created story with title: $title');
                },
              ),
              '/stats': Statistics(),
              '/completedStory': CompletedStoriesPage(),
            };

            Widget currentPage = pages[settings.name] ?? LoginScreen();

            int currentIndex = 1;
            if (settings.name == '/ongoing') {
              currentIndex = 0;
            } else if (settings.name == '/home') {
              currentIndex = 1;
            } else if (settings.name == '/completedStory') {
              currentIndex = 2;
            }

            if (settings.name == '/login' || settings.name == '/signup') {
              return currentPage; // Return the screen without CommonScaffold
            } else {
              return CommonScaffold(
                body: currentPage,
                currentIndex: currentIndex,
                onItemTapped: (int index) {
                  if (index == 0) {
                    Navigator.pushNamed(context, '/ongoing');
                  } else if (index == 1) {
                    Navigator.pushNamed(context, '/home');
                  } else if (index == 2) {
                    Navigator.pushNamed(context, '/completedStory');
                  }
                },
              );
            }
          },
        );
      },
    );
  }
}
