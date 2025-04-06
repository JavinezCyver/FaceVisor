import 'package:flutter/material.dart';
import 'terms_and_condition.dart'; // Ensure this file exists

class SkinFaceVisorScreen extends StatefulWidget {
  @override
  _SkinFaceVisorScreenState createState() => _SkinFaceVisorScreenState();
}

class _SkinFaceVisorScreenState extends State<SkinFaceVisorScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TermsAndConditionsScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "SKIN FACEVISOR",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.black, // Black text color
                fontFamily: 'Arial',
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Spacing between text and loader
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black), // Black loading spinner
              strokeWidth: 3.0,
            ),
          ],
        ),
      ),
    );
  }
}
