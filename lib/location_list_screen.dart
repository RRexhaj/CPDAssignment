import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationListScreen extends StatelessWidget {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("locations");

  LocationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Locations'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: _database.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final locations = data.values.toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent, size: 30),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Latitude: ${location['latitude']}, Longitude: ${location['longitude']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.grey, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              "Time: ${location['timestamp']}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: Text(
              'No locations found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}