import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:map_app/views/chatbot_view.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'views/report_choose.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'views/home_view.dart';
import 'widgets/nav_bar.dart';
import 'views/login_view.dart';
import 'views/explore_view.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  runApp(MaterialApp(
    title: "iSaarthi",
    theme: ThemeData(
      primarySwatch: Colors.green,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF55AD9B),
        foregroundColor: Colors.white,
      ),
    ),
    home: const AuthWrapper(),
    routes: {
      '/home': (context) => const HomeView(),
      '/map': (context) => const MapView(),
      '/login': (context) => const LoginView(),
      '/explore': (context) => const ExploreView(),
      '/chatbot': (context) => ChatbotView(),
    },
    debugShowCheckedModeBanner: false,
  ));
}

final String? yourMapTilerApiKey=dotenv.env['MAPTILER_API_KEY'];

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const HomeView();
          }
          return const LoginView();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
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
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(28.6139, 77.2090);
  Map<String, dynamic>? _selectedIssue;

  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isCentering = false;
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _determinePosition(isInitialLoad: true);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _fetchSuggestions(_searchController.text);
      } else {
        if (mounted) setState(() => _suggestions = []);
      }
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.length < 3) return;
    
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&viewbox=76.8,28.4,77.4,28.9&bounded=1');
    
    try {
      final response = await http.get(url, headers: {'User-Agent': 'CivicWatchApp/1.0'});
      if (response.statusCode == 200) {
        final results = json.decode(response.body) as List;
        if (mounted) {
          setState(() {
            _suggestions = results.cast<Map<String, dynamic>>();
          });
        }
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }

  Future<void> _determinePosition({bool isInitialLoad = false}) async {
    if (!isInitialLoad && mounted) {
      setState(() { _isCentering = true; });
    }

    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() { _isCentering = false; });
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() { _isCentering = false; });
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() { _isCentering = false; });
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      final Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentCenter, 15.0);
      }
    } catch (e) {
      print("Error getting location: $e");
    } finally {
      if (mounted) {
        setState(() { _isCentering = false; });
      }
    }
  }

  Future<void> _searchAndMoveMap(Map<String, dynamic> location) async {
    FocusScope.of(context).unfocus(); 
    
    setState(() {
      _isSearching = true;
      _suggestions = [];
    });

    try {
      final lat = double.parse(location["lat"]);
      final lon = double.parse(location["lon"]);
      _searchController.text = location["display_name"];
      _mapController.move(LatLng(lat, lon), 15.0);
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Could not move to location. $e'), backgroundColor: Colors.red),
        );
    } finally {
      if(mounted) setState(() => _isSearching = false);
    }
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$text filter selected')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF55AD9B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.grey.shade700, size: 24),
      ),
    );
  }

  Widget _buildSelectedIssueCard({required Map<String, dynamic> issue}) {
    final timestamp = issue['timestamp'] as Timestamp?;
    final priority = issue['priority'] as String?;
    final readableLocation = issue['readableLocation'] as String? ?? issue['location'] as String?;
    Coords? destinationCoords;
    final locationData = issue['location'];
    if (locationData is GeoPoint) {
      destinationCoords = Coords(locationData.latitude, locationData.longitude);
    } else if (locationData is String && locationData.contains(',')) {
      final parts = locationData.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim());
        final lon = double.tryParse(parts[1].trim());
        if (lat != null && lon != null) {
          destinationCoords = Coords(lat, lon);
        }
      }
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: _getMarkerColor(priority), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issue['title'] as String? ?? 'No Title', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (timestamp != null)
                        Text('Reported ${timeago.format(timestamp.toDate())}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
                      
                      if (readableLocation != null) ...[
                          const SizedBox(height: 4),
                          Text(readableLocation, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            Text(
              issue['description'] as String? ?? 'No description provided.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (destinationCoords == null) ? null : () async {
                      try {
                        final availableMaps = await MapLauncher.installedMaps;
                        await availableMaps.first.showDirections(
                          destination: destinationCoords!,
                          destinationTitle: issue['title'] ?? 'Issue Location',
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch maps.')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF55AD9B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Get Directions', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.black87),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sharing info feature not implemented yet')));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: _isSearching
                  ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.search, color: Colors.grey),
              hintText: 'Search in Delhi',
              hintStyle: GoogleFonts.inter(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
              suffixIcon: GestureDetector(
                onTap: _isCentering ? null : _determinePosition,
                child: Container(
                  width: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF55AD9B),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(24.0), bottomRight: Radius.circular(24.0)),
                  ),
                  child: _isCentering 
                    ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)))
                    : const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 14.0,
              onTap: (_, __) => setState(() {
                _selectedIssue = null;
                _suggestions = [];
                FocusScope.of(context).unfocus();
              }),
            ),
            children: [
              TileLayer(urlTemplate: 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$yourMapTilerApiKey'),
              
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('issues').where('status', isNotEqualTo: 'Resolved').snapshots(),
                builder: (context, snapshot) {
                  // --- FIX 1: Added explicit error handling ---
                  if (snapshot.hasError) {
                    print("Firestore Stream Error: ${snapshot.error}");
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.black54,
                        child: const Text("Error loading issues.", style: TextStyle(color: Colors.white)),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink(); // Show nothing while loading
                  }
                  
                  // --- FIX 2: Added explicit check for empty data ---
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // You can optionally show a message here if no issues are found
                    return const SizedBox.shrink();
                  }

                  List<Marker> markers = [];
                  for (var doc in snapshot.data!.docs) {
                    try {
                      final data = doc.data() as Map<String, dynamic>;
                      final locationData = data['location'];
                      LatLng? markerPoint;

                      if (locationData is GeoPoint) {
                        markerPoint = LatLng(locationData.latitude, locationData.longitude);
                      } else if (locationData is String && locationData.contains(',')) {
                        final parts = locationData.split(',');
                        if (parts.length == 2) {
                          final lat = double.tryParse(parts[0].trim());
                          final lon = double.tryParse(parts[1].trim());
                          if (lat != null && lon != null) {
                            markerPoint = LatLng(lat, lon);
                          }
                        }
                      }
                      
                      if (markerPoint != null) {
                        markers.add(
                          Marker(
                            width: 48.0,
                            height: 48.0,
                            point: markerPoint,
                            child: GestureDetector(
                              // --- FIX 3: Made data handling safer ---
                              onTap: () {
                                final issueData = Map<String, dynamic>.from(data);
                                issueData['id'] = doc.id;
                                setState(() => _selectedIssue = issueData);
                              },
                              child: Icon(
                                Icons.location_pin,
                                size: 48.0,
                                color: _getMarkerColor(data['priority'] as String?),
                                shadows: const [ Shadow(color: Colors.black87, offset: Offset(1, 1), blurRadius: 2.0) ],
                              ),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      // Added a more specific print statement
                      print("Error parsing document ${doc.id}: $e. Skipping marker.");
                    }
                  }

                  return MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      size: const Size(40, 40),
                      builder: (context, markers) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF55AD9B),
                          ),
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                      markers: markers,
                    ),
                  );
                },
              ),
            ],
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _buildFilterButton('Incidents', true),
                const SizedBox(width: 8),
                _buildFilterButton('Mood', false),
                const Spacer(),
                _buildCircleButton(Icons.tune, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter options coming soon!')));
                }),
              ],
            ),
          ),

          if (_suggestions.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight - 8,
              left: 16,
              right: 16,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.location_city, color: Color(0xFF55AD9B)),
                        title: Text(suggestion['display_name'], maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => _searchAndMoveMap(suggestion),
                      );
                    },
                  ),
                ),
              ),
            ),
          
          if (_selectedIssue != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: _buildSelectedIssueCard(issue: _selectedIssue!),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReportChooserView())),
        backgroundColor: const Color(0xFF55AD9B),
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Color _getMarkerColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
