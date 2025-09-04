import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Get current position
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
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

  // Combined function to get current area name
  static Future<String> getCurrentAreaName() async {
    try {
      Position position = await getCurrentPosition();
      return await getAreaName(position.latitude, position.longitude);
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}

/*// Usage Example Widget
class LocationWidget extends StatefulWidget {
  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String _areaName = 'Tap to get location';
  bool _isLoading = false;

  void _getLocation() async {
    setState(() {
      _isLoading = true;
    });

    String areaName = await LocationService.getCurrentAreaName();

    setState(() {
      _areaName = areaName;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Current Location')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _areaName,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _getLocation,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Get Current Location'),
            ),
          ],
        ),
      ),
    );
  }
}*/