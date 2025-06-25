import 'package:flutter/material.dart';

import 'height_screen.dart';

// Import the height page
// import 'height_input_page.dart'; // Uncomment this line and adjust the path

class GenderSelectionPage extends StatefulWidget {
  @override
  _GenderSelectionPageState createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_gender.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.withOpacity(0.7),
                Colors.purple.withOpacity(0.8),
                Colors.black.withOpacity(0.6),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // Title
                  const Text(
                    'Choose Your Gender',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  const Text(
                    'To give you better experience and result\nwe need to know your gender',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 60),

                  // Gender Selection Buttons
                  _buildGenderButton(
                    icon: Icons.male,
                    label: 'Male',
                    value: 'male',
                  ),

                  const SizedBox(height: 16),

                  _buildGenderButton(
                    icon: Icons.female,
                    label: 'Female',
                    value: 'female',
                  ),

                  const SizedBox(height: 16),

                  _buildGenderButton(
                    icon: Icons.transgender,
                    label: 'Others',
                    value: 'others',
                  ),

                  const Spacer(),

                  // Progress Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProgressDot(false),
                      const SizedBox(width: 8),
                      _buildProgressDot(true),
                      const SizedBox(width: 8),
                      _buildProgressDot(false),
                      const SizedBox(width: 8),
                      _buildProgressDot(false),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required IconData icon,
    required String label,
    required String value,
  }) {
    bool isSelected = selectedGender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = value;
        });

        // Navigate to height page after selection
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HeightInputPage()),
          );
        });
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 24),
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? Colors.pink : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
