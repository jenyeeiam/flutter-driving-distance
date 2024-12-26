import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

void main() {
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
    });
    // Cancel the subscription but keep the last position
    _positionStreamSubscription?.pause();
  }

  void _clearTracking() {
    setState(() {
      _isTracking = false;
      _totalDistance = 0.0;
      _lastPosition = null;
    });
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null; // Reset the subscription
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
          ],
        ),
      ),
    );
  }
}
