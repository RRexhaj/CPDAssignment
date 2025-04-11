import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _location = 'Fetching location...';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services are disabled.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Location permissions are permanently denied.';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
    });

    // Save location to Firebase
    DatabaseReference ref = FirebaseDatabase.instance.ref("locations");
    await ref.push().set({
      "latitude": position.latitude,
      "longitude": position.longitude,
      "timestamp": DateTime.now().toIso8601String(),
    });

    // Show a notification
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('location_channel', 'Location Updates',
            importance: Importance.high, priority: Priority.high);
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Location Updated',
      'Your location is now: $_location',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Location'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _location,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20), // Add spacing between the text and button
            ElevatedButton(
              onPressed: () async {
                DatabaseReference ref = FirebaseDatabase.instance.ref("locations");
                DataSnapshot snapshot = await ref.get();
                print(snapshot.value); // Display data in the console or UI
              },
              child: const Text('Fetch Saved Locations'),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationListScreen extends StatelessWidget {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("locations");

  LocationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Locations'),
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
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                return ListTile(
                  title: Text(
                      "Lat: ${location['latitude']}, Lng: ${location['longitude']}"),
                  subtitle: Text("Time: ${location['timestamp']}"),
                );
              },
            );
          }

          return const Center(child: Text('No locations found.'));
        },
      ),
    );
  }
}