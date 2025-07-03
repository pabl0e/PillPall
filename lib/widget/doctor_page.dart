import 'package:flutter/material.dart';

class DoctorPage extends StatelessWidget {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFDDED),
      appBar: AppBar(
        title: Text(
          'Doctor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[900],
          ),
        ),
        backgroundColor: Color(0xFFFFDDED),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.deepPurple[900]),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              size: 120,
              color: Colors.deepPurple[300],
            ),
            SizedBox(height: 20),
            Text(
              'Feature Coming Soon!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[900],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We\'re working on bringing you the best doctor consultation experience.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.deepPurple[700]),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                'Go Back',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
