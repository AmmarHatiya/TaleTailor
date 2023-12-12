import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'account_page.dart';

class CommonScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final void Function(int) onItemTapped;

  const CommonScaffold({
    required this.body,
    required this.currentIndex,
    required this.onItemTapped,
  });
  Future<void> _signOutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Tale Tailor",
            style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontStyle: FontStyle.italic,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7E57C2))),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_box, color: Colors.deepPurple.shade400),
            onSelected: (value) {
              if (value == 'account') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountPage()),
                );
              } else if (value == 'logout') {
                _signOutUser(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'account',
                child: Text('Account'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Log Out'),
              ),
            ],
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.deepPurpleAccent.shade400,
          currentIndex: currentIndex,
          onTap: onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.edit_road_rounded,
                  size: 30,
                ),
              ),
              label: 'Ongoing',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  size: 30,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.done_all_rounded,
                  size: 30,
                ),
              ),
              label: 'Completed',
            ),
          ],
          selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
          //unselectedItemColor: const Color.fromARGB(255, 198, 177, 255),
        ),
      ),
    );
  }
}
