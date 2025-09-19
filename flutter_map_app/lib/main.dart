import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'views/report_choose.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'views/home_view.dart';
import 'widgets/nav_bar.dart';
import 'views/login_view.dart';

const String yourMapTilerApiKey = 'WCthTmHiFHsTzAuLYrKr';
// ----------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: "Civic Watch",
    theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF55AD9B),
          foregroundColor: Colors.white,
        )),
    home: const AuthWrapper(),
    routes: {
      '/home': (context) => const HomeView(),
      '/map': (context) => const MapView(),
      '/login': (context) => const LoginView(), 
    },
  ));
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeView();
        } else {
          return const LoginView();
        }
      },
    );
  }
}


class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  LatLng? _initialCenter;
  final MapController _mapController = MapController();
  Map<String, dynamic>? _selectedIssue;
  
  @override
  void initState() {
    super.initState();
    _initializeMapLocation();
  }

  Future<void> _initializeMapLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) setState(() => _initialCenter = LatLng(position.latitude, position.longitude));
    } catch (e) {
      if (mounted) setState(() => _initialCenter = const LatLng(28.6139, 77.2090));
    }
  }

  void _onMarkerTap(Map<String, dynamic> issueDataWithId) {
    setState(() => _selectedIssue = issueDataWithId);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialCenter == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('issues').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const Center(child: Text('Could not connect to database.'));
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    
                    final markers = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final lat = data['latitude'] ?? 0.0;
                      final lng = data['longitude'] ?? 0.0;
                      return Marker(
                        width: 80.0, height: 80.0, point: LatLng(lat, lng),
                        child: GestureDetector(
                          onTap: () => _onMarkerTap({...data, 'id': doc.id}),
                          child: Icon(Icons.location_pin, color: _getMarkerColor(data['priority']), size: 40.0),
                        ),
                      );
                    }).toList();

                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialCenter!,
                        initialZoom: 14.0,
                        onTap: (_, __) => setState(() => _selectedIssue = null)
                      ),
                      children: [
                        TileLayer(urlTemplate: 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$yourMapTilerApiKey'),
                        MarkerLayer(markers: markers),
                      ],
                    );
                  },
                ),
                if (_selectedIssue != null)
                  IssueDetailSheet(issue: _selectedIssue!),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReportChooserView())),
        backgroundColor: const Color(0xFF55AD9B),
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
  
  Color _getMarkerColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.blue;
    }
  }
}

class IssueDetailSheet extends StatelessWidget {
  final Map<String, dynamic> issue;
  const IssueDetailSheet({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(); 
  }
}