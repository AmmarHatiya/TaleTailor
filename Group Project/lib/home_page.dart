import 'package:creative_writing_app/statistics.dart';
import 'package:flutter/material.dart';



// Consists of page to navigate to the most important pages and show helpful information to the user
// Still need to implement users stats and create story page. As well as showing recent contributions.
// Will be accessed through the database once made and stored there.
class HomePage extends StatelessWidget {
  final buttonWidth = 350.0;
  final buttonHeight = 100.0;

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity, // Full screen width
            height: 500, // Full screen height
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('./assets/images/home_illustration.png'), // Adjust the image path
                fit: BoxFit.cover, // You can use different BoxFit values based on your needs
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // Align at the bottom
              children: [
                // Your content here
                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Takes user to create_new_story page. createNewStory
                      Navigator.pushNamed(context, '/createStory');
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => CreateNewStory()),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                      ),
                      textStyle: const TextStyle(fontSize: 20),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('New Entry'),
                        Icon(
                          Icons.add_box,
                          size: 50,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Add spacing between the buttons


                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Statistics()),
                      );                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                      ),
                      textStyle: const TextStyle(fontSize: 20),
                      backgroundColor: Colors.grey.shade900,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Stats'),
                        Icon(
                          Icons.pie_chart_outline,
                          size: 50,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50), // Add spacing between the buttons
              ],
            ),
          ),
        ],
      ),
    );
  }
}
