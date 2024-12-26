import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'google_sheets_helper.dart';
import 'google_credentials.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MileageTracker());
}

class MileageTracker extends StatelessWidget {
  const MileageTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driving Distance Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Driving Distance Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isTracking = false;
  double _totalDistance = 0.0;
  double _distanceDuringPause = 0.0; // Hold paused distance
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  void _startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return;
    }

    setState(() {
      _isTracking = true;
      _distanceDuringPause = 0.0; // Reset paused distance
      _lastPosition = null; // Reset the last position
    });

    // Start listening to position updates
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (_isTracking && _lastPosition != null) {
        double distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        setState(() {
          _totalDistance += distance;
        });
      }
      _lastPosition = position;
    });
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _distanceDuringPause = 0.0; // Reset the paused distance
    });
    _positionStreamSubscription?.pause();
  }

  void _clearTracking() {
    setState(() {
      _isTracking = false;
      _totalDistance = 0.0;
      _lastPosition = null;
    });
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Function to add a new row to Google Sheet
  void _addRowToGoogleSheet() async {
    // Initialize the helper
    final googleSheetsHelper = GoogleSheetsHelper(
      spreadsheetId: GoogleCredentials.spreadsheetId,  // Use the ID from GoogleCredentials
    );

    // Format the date and round kilometers
    final today = DateTime.now();
    final formattedDate = "${today.month.toString().padLeft(2, '0')}/${today.day.toString().padLeft(2, '0')}/${today.year}";
    final roundedKilometers = (_totalDistance / 1000).ceil();

    // Append the row
    try {
      await googleSheetsHelper.appendRow([formattedDate, roundedKilometers]);

      // Notify the user of success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data saved to Google Sheet!")),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save data to Google Sheet!")),
      );
      print(e);
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Total Distance:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${(_totalDistance / 1000).toStringAsFixed(2)} kilometers',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isTracking ? _stopTracking : _startTracking,
              child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearTracking,
              child: const Text('Clear Tracker'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addRowToGoogleSheet,
              child: const Text('Save to Google Sheet'),
            ),
          ],
        ),
      ),
    );
  }
}
