import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Show alert dialog for location services
  static Future<void> _showLocationServiceDialog(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Location services are currently disabled. Please enable them in your device settings to use this feature.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  // Show alert dialog for permission denied
  static Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location permission to work properly. Please grant location access.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Grant Permission'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show alert dialog for permanently denied permissions
  static Future<void> _showPermanentlyDeniedDialog(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Location Permission Permanently Denied'),
          content: const Text(
            'Location permissions are permanently denied. Please enable them manually in app settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open App Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  // Get current position with context for dialogs
  static Future<Position?> getCurrentPosition(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showLocationServiceDialog(context);
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await _showPermissionDeniedDialog(context);
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showPermanentlyDeniedDialog(context);
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      // Show Cupertino error dialog for any other location errors
      await showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Location Error'),
            content: Text('Failed to get location: ${e.toString()}'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return null;
    }
  }

  // Get area name from coordinates
  static Future<String> getAreaName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.isoCountryCode}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Error getting location name';
    }
  }

  // Combined function to get current area name with context
  static Future<String?> getCurrentAreaName(BuildContext context) async {
    try {
      Position? position = await getCurrentPosition(context);
      if (position == null) {
        return null; // User cancelled or permission denied
      }
      return await getAreaName(position.latitude, position.longitude);
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}