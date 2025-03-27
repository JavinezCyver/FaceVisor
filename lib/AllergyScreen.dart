import 'package:flutter/material.dart';
import 'package:vs_flutter_proj/home_screen.dart';

class AllergyScreen extends StatefulWidget {
  const AllergyScreen({super.key});

  @override
  _AllergyScreenState createState() => _AllergyScreenState();
}

class _AllergyScreenState extends State<AllergyScreen> {
  final TextEditingController _allergyController = TextEditingController();
  List<String> allergies = [];
  bool hasAllergies = false;

  void _addAllergy() {
    String allergy = _allergyController.text.trim();
    if (allergy.isNotEmpty && !allergies.contains(allergy)) {
      setState(() {
        allergies.add(allergy);
        _allergyController.clear();
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      allergies.remove(allergy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Face\nSkinVisor",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Getting to know you",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox for allergies
                      Row(
                        children: [
                          Checkbox(
                            value: hasAllergies,
                            onChanged: (value) {
                              setState(() {
                                hasAllergies = value!;
                              });
                            },
                          ),
                          Text(
                            "Do you have any allergies?",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      if (hasAllergies) ...[
                        SizedBox(height: 10),

                        // Allergy input field
                        TextField(
                          controller: _allergyController,
                          decoration: InputDecoration(
                            labelText: "List all your allergies here",
                            hintText: "Type here",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: _addAllergy,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) => _addAllergy(),
                        ),

                        SizedBox(height: 10),

                        // List of allergies
                        Text(
                          "List of allergies",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),

                        Column(
                          children: allergies
                              .map(
                                (allergy) => Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: ListTile(
                                    title: Text(allergy),
                                    trailing: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () => _removeAllergy(allergy),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Proceed Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (Context) => HomeScreen()),
                  ); // Handle navigation to the next step
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text("Proceed", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
