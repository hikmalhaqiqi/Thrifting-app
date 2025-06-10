import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Lokasi statis toko (bisa diganti sesuai kebutuhan)
  static const double _tokoLat = -7.7956; // Yogyakarta
  static const double _tokoLng = 110.3695;
  static const String _tokoName = "Second Loop Store";
  static const String _tokoAddress = "Jl. Malioboro No. 123, Yogyakarta";

  // Lokasi pengguna saat ini
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String _locationStatus = "Belum mendapatkan lokasi";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Method untuk mendapatkan lokasi pengguna saat ini
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = "Mengambil lokasi...";
    });

    try {
      // Cek izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = "Izin lokasi ditolak";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = "Izin lokasi ditolak secara permanen";
          _isLoadingLocation = false;
        });
        return;
      }

      // Dapatkan posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _locationStatus = "Lokasi berhasil didapatkan";
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = "Error: ${e.toString()}";
        _isLoadingLocation = false;
      });
    }
  }

  // Method untuk menghitung jarak antara dua lokasi
  String _calculateDistance() {
    if (_currentPosition == null) return 'Lokasi tidak tersedia';

    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _tokoLat,
      _tokoLng,
    );

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  // Method untuk membuka Google Maps
  Future<void> _openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$_tokoLat,$_tokoLng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
      );
    }
  }

  // Method untuk membuka navigasi ke toko
  Future<void> _openNavigation() async {
    if (_currentPosition != null) {
      final url =
          'https://www.google.com/maps/dir/${_currentPosition!.latitude},${_currentPosition!.longitude}/$_tokoLat,$_tokoLng';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka navigasi')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi Anda belum tersedia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Map Lokasi Toko Online',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card Toko
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.store, color: Colors.blueGrey, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _tokoName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _tokoAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.navigation, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Jarak: ${_calculateDistance()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Status Lokasi Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.my_location, color: Colors.blue, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Status Lokasi Anda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_isLoadingLocation)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Mengambil lokasi...'),
                        ],
                      )
                    else
                      Text(
                        _locationStatus,
                        style: TextStyle(
                          color: _currentPosition != null
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    if (_currentPosition != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                        'Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Koordinat Toko
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Koordinat Toko',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Latitude: $_tokoLat',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Longitude: $_tokoLng',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openGoogleMaps,
                    icon: const Icon(Icons.map),
                    label: const Text('Buka di Google Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openNavigation,
                    icon: const Icon(Icons.directions),
                    label: const Text('Navigasi ke Toko'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Lokasi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
