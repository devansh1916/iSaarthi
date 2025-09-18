import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'views/register_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'views/report_issue_view.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:ui' as ui; // Import with an alias to resolve the conflict
import 'views/home_view.dart'; 
import 'package:intl/intl.dart'; 

<<<<<<< Updated upstream:flutter_map_app/lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      title: "Map app",
      theme: ThemeData(primaryColor: Colors.cyanAccent),
      home: const RegisterView(),
    ),
  );
}

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: FullscreenWebView());
  }
=======
// --- IMPORTANT: PASTE YOUR MAPTILER API KEY HERE ---
const String yourMapTilerApiKey = 'WCthTmHiFHsTzAuLYrKr#-0.0/7.34655/-32.36416';
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
    home: const RegisterView(),
  ));
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
>>>>>>> Stashed changes:lib/main.dart
}

class _MapViewState extends State<MapView> {
  LatLng? _initialCenter;
  String? _locationError;
  final MapController _mapController = MapController();
  Map<String, dynamic>? _selectedIssue;
  int _currentIndex = 2; // Set initial index to Map

  @override
<<<<<<< Updated upstream:flutter_map_app/lib/main.dart
  State<FullscreenWebView> createState() => _FullscreenWebViewState();
}

class _FullscreenWebViewState extends State<FullscreenWebView> {
  late final WebViewController _controller;
  final String url =
      "https://api.maptiler.com/maps/0197cb4e-5175-7b8e-a05b-7119c556c260/?key=WCthTmHiFHsTzAuLYrKr#1.0/0.00000/0.00000";

  @override
=======
>>>>>>> Stashed changes:lib/main.dart
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // ... (location logic remains the same)
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationError = 'Location services are disabled. Please enable them.';
        _initialCenter = const LatLng(28.6139, 77.2090); // Fallback
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.denied) {
       setState(() {
        _locationError = 'Location permissions are denied. Map is centered on a default location.';
        _initialCenter = const LatLng(28.6139, 77.2090); // Fallback
      });
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError = 'Location permissions are permanently denied. Please enable location for this app in your device settings.';
        _initialCenter = const LatLng(28.6139, 77.2090); // Fallback
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        _initialCenter = LatLng(position.latitude, position.longitude);
        _locationError = null; // Clear any previous errors
      });
    } catch (e) {
      print("Error getting location: $e");
       setState(() {
        _locationError = 'Failed to get location. Please try again.';
        _initialCenter = const LatLng(28.6139, 77.2090); // Fallback on error
      });
    }
  }

  void _onMarkerTap(Map<String, dynamic> issueDataWithId) {
    setState(() {
      _selectedIssue = issueDataWithId;
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0: // Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
        break;
      case 1: // Explore (Placeholder)
        break;
      case 2: // Map (Current page)
        break;
      case 3: // Chatbot (Placeholder)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream:flutter_map_app/lib/main.dart
    return Scaffold(body: WebViewWidget(controller: _controller));
=======
    if (yourMapTilerApiKey == 'YOUR_MAPTILER_API_KEY') {
      return Scaffold(
        appBar: AppBar(title: const Text('Configuration Error')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Please replace "YOUR_MAPTILER_API_KEY" in main.dart with your actual MapTiler API key.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      body: _initialCenter == null
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 10), Text("Fetching your location...")],))
          : _locationError != null && _locationError!.contains('permanently')
            ? _buildPermissionDeniedUI()
            : Stack(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('issues').snapshots(),
                  builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    
                    List<Marker> markers = [];
                    if (snapshot.hasData) {
                        markers = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final dataWithId = {...data, 'id': doc.id};
                        final lat = data['latitude'] ?? 28.6139 + (doc.hashCode % 1000) * 0.0001;
                        final lng = data['longitude'] ?? 77.2090 + (doc.hashCode % 1000) * 0.0001;

                        return Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(lat, lng),
                          child: GestureDetector(
                            onTap: () => _onMarkerTap(dataWithId),
                            child: Tooltip(
                              message: data['issue'] ?? 'No Title',
                              child: Icon(
                                Icons.location_pin,
                                color: _getMarkerColor(data['priority'] ?? 'low'),
                                size: 40.0,
                              ),
                            ),
                          ),
                        );
                      }).toList();
                    }

                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialCenter!,
                        initialZoom: 14.0,
                        onTap: (_, __) { 
                          setState(() {
                            _selectedIssue = null;
                          });
                        }
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$yourMapTilerApiKey',
                          userAgentPackageName: 'com.example.map_app',
                        ),
                        MarkerLayer(markers: markers),
                      ],
                    );
                  },
                ),
                _buildMapUI(),
                if (_selectedIssue != null)
                  IssueDetailSheet(issue: _selectedIssue!),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ReportIssueView()),
          );
        },
        backgroundColor: const Color(0xFF55AD9B),
        child: const Icon(Icons.camera_alt),
        elevation: 2.0,
        shape: const CircleBorder(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  
  Widget _buildMapUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4)
                  )
                ]
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search location in Delhi',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15)
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildFilterChip('Incidents', true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Mood', false),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4)
                      )
                    ]
                  ),
                  child: const Icon(Icons.filter_list),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? const Color(0xFF55AD9B) : Colors.white,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
  
  Widget _buildBottomNavigationBar() {
  return BottomAppBar(
    shape: const CircularNotchedRectangle(),
    notchMargin: 6.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildNavBarItem(Icons.home_outlined, "Home", 0),
        _buildNavBarItem(Icons.search, "Explore", 1),
        const SizedBox(width: 40), // The space for the FAB
        _buildNavBarItem(Icons.map_outlined, "Map", 2),
        _buildNavBarItem(Icons.chat_bubble_outline, "Chatbot", 3),
      ],
    ),
  );
}

Widget _buildNavBarItem(IconData icon, String label, int index) {
  final isSelected = _currentIndex == index;
  return InkWell(
    onTap: () => _onNavBarTapped(index),
    borderRadius: BorderRadius.circular(30),
    child: Padding(
      // FIX: Reduced vertical padding to prevent overflow
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            color: isSelected ? const Color(0xFF55AD9B) : Colors.grey,
          ),
          // FIX: Add a small SizedBox to give just enough space
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF55AD9B) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

  
  Widget _buildPermissionDeniedUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _locationError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMarkerColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.blue;
    }
  }
}

class IssueDetailSheet extends StatelessWidget {
  final Map<String, dynamic> issue;

  const IssueDetailSheet({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    DateTime? issueDate;
    final timestamp = issue['timestamp'];
    if (timestamp is Timestamp) {
      issueDate = timestamp.toDate();
    } else if (timestamp is String) {
      issueDate = DateTime.tryParse(timestamp);
    }

    String reportedTime = 'a while ago'; 
    if (issueDate != null) {
      final timeAgo = DateTime.now().difference(issueDate);
      if (timeAgo.inMinutes < 60) {
        reportedTime = '${timeAgo.inMinutes} minutes ago';
      } else if (timeAgo.inHours < 24) {
        reportedTime = '${timeAgo.inHours} hours ago';
      } else {
        reportedTime = '${timeAgo.inDays} days ago';
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                issue['issue'] ?? 'No Title',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Reported $reportedTime',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              DescriptionWidget(issue: issue),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF55AD9B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Get Directions', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                   Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                         side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Share', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class DescriptionWidget extends StatelessWidget {
  final Map<String, dynamic> issue;
  const DescriptionWidget({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    String description = issue['description'] ?? 'No description provided.';
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(text: description, style: const TextStyle(fontSize: 16, height: 1.5));
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: 3,
          textDirection: ui.TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (textPainter.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, height: 1.5)),
              GestureDetector(
                onTap: () => _showFullDetailDialog(context, issue),
                child: const Text(
                  'See More',
                  style: TextStyle(color: Color(0xFF55AD9B), fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        } else {
          return Text(description, style: const TextStyle(fontSize: 16, height: 1.5));
        }
      },
    );
  }

  void _showFullDetailDialog(BuildContext context, Map<String, dynamic> issue) {
     DateTime? issueDate;
    final timestamp = issue['timestamp'];
    if (timestamp is Timestamp) {
      issueDate = timestamp.toDate();
    } else if (timestamp is String) {
      issueDate = DateTime.tryParse(timestamp);
    }

    final formattedDate = issueDate != null 
      ? DateFormat.yMMMd().add_jms().format(issueDate) 
      : 'N/A';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(issue['issue'] ?? 'Issue Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow('Description:', issue['description'] ?? 'N/A'),
                _buildDetailRow('Location:', issue['location'] ?? 'N/A'),
                _buildDetailRow('Priority:', issue['priority'] ?? 'N/A'),
                _buildDetailRow('Department:', issue['department'] ?? 'N/A'),
                _buildDetailRow('Reported By:', issue['reportedBy'] ?? 'N/A'),
                _buildDetailRow('Reported On:', formattedDate),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
>>>>>>> Stashed changes:lib/main.dart
  }
}
