import 'package:flutter/material.dart';
import 'location_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LocationScreen()),
            );
          },
          child: const Text('Track Location'),
        ),
      ),
    );
  }
}