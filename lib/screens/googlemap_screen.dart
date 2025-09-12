import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

import 'package:iconsax_flutter/iconsax_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _controller;
  TextEditingController _searchController = TextEditingController();

  // Initial position (San Francisco)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12.0,
  );

  Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get current user location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _moveCamera(LatLng(position.latitude, position.longitude));
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  // Move camera to specific location
  void _moveCamera(LatLng position) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );
  }

  // Search for location
  Future<void> _searchLocation() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng position = LatLng(location.latitude, location.longitude);

        _addMarker(position, 'Search Result');
        _moveCamera(position);
        _getAddressFromLatLng(position);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found: $query')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Add marker to map
  void _addMarker(LatLng position, String markerId) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(
            title: markerId,
            snippet: _selectedAddress,
          ),
        ),
      );
      _selectedLocation = position;
    });
  }

  // Get address from coordinates
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          _selectedAddress =
          '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  // Handle map tap
  void _onMapTap(LatLng position) {
    _addMarker(position, 'Selected Location');
    _getAddressFromLatLng(position);
  }

  // Clear search and markers
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _markers.clear();
      _selectedLocation = null;
      _selectedAddress = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Maps Search & Pick',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Iconsax.arrow_left_2_copy)
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFF4E6BF5),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: _markers,
            onTap: _onMapTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a location...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                      onSubmitted: (_) => _searchLocation(),
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearSearch,
                    ),
                ],
              ),
            ),
          ),

          // Selected Location Info
          if (_selectedLocation != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _selectedAddress.isNotEmpty
                          ? _selectedAddress
                          : 'Loading address...',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                          'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle location selection
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Location Selected'),
                              content: Text('Location: $_selectedAddress'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E6BF5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                            'Select This Location',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // My Location Button
          Positioned(
            bottom: _selectedLocation != null ? 220 : 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: const Color(0xFF4E6BF5)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}