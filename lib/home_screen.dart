import 'package:cpdassignmentrei/location_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("locations");
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String _location = '';
  LatLng? _currentLatLng; // Store the current location for the map
  GoogleMapController? _mapController; // Controller for Google Map

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestNotificationPermission(); // Request notification permission for Android 13+
  }

  // Initialize the notification plugin
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Request notification permission for Android 13+
  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Send a notification
  Future<void> _sendNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id', // Unique channel ID
      'Location Updates', // Channel name
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0, // Notification ID
      'Location Tracker', // Notification title
      message, // Notification body
      notificationDetails,
    );
  }

  // Fetch the current location
  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = 'Location services are disabled. Please enable them.';
        });
        return;
      }

      // Check and request location permissions
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

      // Get the current location
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Save location to Firebase
      final location = {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "timestamp": DateTime.now().toIso8601String(),
      };

      await FirebaseDatabase.instance.ref("locations").push().set(location);

      // Log the event to Firebase Analytics
      await FirebaseAnalytics.instance.logEvent(
        name: 'location_fetched',
        parameters: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      );

      // Update the UI
      setState(() {
        _location = 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
        _currentLatLng = LatLng(position.latitude, position.longitude); // Update map location
      });

      // Send a notification
      await _sendNotification("Location updated: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      setState(() {
        _location = 'Failed to get location: $e';
      });
    }
  }

  // Zoom in the map
  void _zoomIn() {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  // Zoom out the map
  void _zoomOut() {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
      ),
      body: Stack(
        children: [
          _currentLatLng == null
              ? const Center(child: Text('Press the button to get your location'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('currentLocation'),
                      position: _currentLatLng!,
                      infoWindow: const InfoWindow(title: 'Current Location'),
                    ),
                  },
                  zoomControlsEnabled: false, // Disable default zoom controls
                  onMapCreated: (controller) {
                    _mapController = controller; // Assign the map controller
                  },
                ),
          Positioned(
            bottom: 100,
            right: 10,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(48, 48), // Larger touch target
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(48, 48), // Larger touch target
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: const Text('Get Current Location'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(48, 48), // Larger touch target
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LocationListScreen()),
                    );
                  },
                  child: const Text('View Stored Locations'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(48, 48), // Larger touch target
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResponsiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Screen'),
      ),
      body: Center(
        child: screenWidth < 600
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Small Screen Layout', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  Icon(Icons.phone_android, size: 50),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Large Screen Layout', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 20),
                  Icon(Icons.desktop_windows, size: 50),
                ],
              ),
      ),
    );
  }
}