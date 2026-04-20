import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
// Handle login logic
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  late Future<Database> database;

  @override
  void initState() {
    super.initState();
    // Open SQLite database when the widget is created
    openDatabaseFunction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/taletailorlogo.png',
                      width: 300,
                      height: 300,
                    ),
                    SizedBox(height: 18),
                    TextField(
                      controller: username,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 18),
                    TextField(
                      controller: password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          QuerySnapshot querySnapshot = await FirebaseFirestore
                              .instance
                              .collection('Account-info')
                              .where('username',
                                  isEqualTo: username.text.trim())
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            String email =
                                querySnapshot.docs.first.get('email');
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .signInWithEmailAndPassword(
                              email: email,
                              password: password.text.trim(),
                            );

                            await saveLoginInfo(email, password.text.trim());

                            print(
                                "User logged in: ${userCredential.user?.uid}");
                            Navigator.pushReplacementNamed(context, '/home');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Username not found",
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (e) {
                          print("Error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Login failed",
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple,
                        padding: EdgeInsets.symmetric(horizontal: 50),
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 13),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: Text(
                            'Create new one',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> openDatabaseFunction() async {
    database = openDatabase(
      'login_info.db',
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE login_info(id INTEGER PRIMARY KEY, email TEXT, password TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> saveLoginInfo(String email, String password) async {
    final Database db = await database;

    await db.insert(
      'login_info',
      {'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
