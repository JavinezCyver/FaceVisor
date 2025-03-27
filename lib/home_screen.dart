import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Captureimage.dart';
import 'Uploadimage.dart';
import 'main.dart'; // Make sure you have this file for logout

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "User";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate to Login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome,\n$username',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Face',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Text(
              'SkinVisor',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Icon(Icons.menu, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'View Past Analysis Reports',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(Icons.image, 'Upload Image', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  UploadImageScreen()),
                  );
                }),
                const SizedBox(width: 10),
                _buildActionButton(Icons.camera_alt, 'Capture Image', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CaptureImageScreen()),
                  );
                }),
              ],
            ),
            const Spacer(),
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.white,),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
      ),
      onPressed: _logout,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.logout, size: 20),
          SizedBox(width: 5),
          Text('Log Out'),
        ],
      ),
    );
  }
}
