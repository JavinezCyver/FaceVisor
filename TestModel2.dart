import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;

class TestModel2 extends StatefulWidget {
  const TestModel2({super.key});

  @override
  _TestModel2State createState() => _TestModel2State();
}

class _TestModel2State extends State<TestModel2> {
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;
  String _result = '';
  String? _processedImageUrl;
  int? _objectCount;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = '';
        _processedImageUrl = null;
        _objectCount = null;
      });
    }
  }

  Future<void> _sendImageToRoboflow() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://serverless.roboflow.com/infer/workflows/code-qjcxw/detect-count-and-visualize'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'api_key': 'LGJpUgdRWaxjZJILrf7F',
          'inputs': {
            'image': {'type': 'base64', 'value': base64Image}
          }
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _processedImageUrl = data['visualization'];
          _objectCount = data['results']?['count'];
          _result = const JsonEncoder.withIndent('  ').convert(data); // Pretty JSON
        });
      } else {
        setState(() {
          _result = 'Error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Upload Image',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.white),
                            SizedBox(width: 10),
                            Text('Insert Image from Gallery', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please make sure the image is clear before proceeding',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    _image != null
                        ? Image.file(_image!, height: 200, width: 200, fit: BoxFit.cover)
                        : const Text('(No image file selected)', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _sendImageToRoboflow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              if (_objectCount != null)
                Text('Detected Objects: $_objectCount', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              if (_processedImageUrl != null)
                Column(
                  children: [
                    const Text("Processed Image:"),
                    const SizedBox(height: 8),
                    Image.network(_processedImageUrl!, height: 200),
                  ],
                ),
              const SizedBox(height: 20),
              if (_result.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Raw Response:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          child: Text(_result, style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                          Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                          );
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 5),
                    Text("Back"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
