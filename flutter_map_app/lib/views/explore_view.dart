import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '/widgets/nav_bar.dart';
import 'report_choose.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4DB6AC);
    const Color darkPrimaryColor = Color(0xFF00796B);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          _buildBackgroundCircles(primaryColor),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Explore Delhi!',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSearchBar(primaryColor),
                    const SizedBox(height: 24),
                    _buildTopCards(primaryColor, darkPrimaryColor),
                    const SizedBox(height: 24),
                    _buildTrendingIssues(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ReportChooserView()),
          );
        },
        backgroundColor: primaryColor,
        elevation:4.0,
        shape:const CircleBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white,size:28),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildBackgroundCircles(Color primaryColor) {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildSearchBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: primaryColor),
          hintText: "Search",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTopCards(Color primaryColor, Color darkPrimaryColor) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
      children: <Widget>[
        WeatherCard(primaryColor: primaryColor, darkPrimaryColor: darkPrimaryColor),
        const TrafficCard(), 
        const AqiCard(),
        const LeaderboardCard(),
      ],
    );
  }
  
  Widget _buildTrendingIssues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending Issues',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildIssueCard(
          'Pothole on XYZ Road',
          'A large pothole causing traffic jams and damage to vehicles.',
        ),
        const SizedBox(height: 16),
        _buildIssueCard(
          'Garbage Dump at ABC Street',
          'Illegal garbage dumping site is becoming a health hazard for the local residents.',
        ),
      ],
    );
  }

  Widget _buildIssueCard(String title, String description) {
    return Card(
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        trailing: Icon(Icons.trending_up, color: Colors.amber.shade800),
      ),
    );
  }
}

final String? openWeatherApiKey=dotenv.env['openWeatherApiKey'];
class WeatherCard extends StatefulWidget {
  final Color primaryColor;
  final Color darkPrimaryColor;
  const WeatherCard({super.key, required this.primaryColor, required this.darkPrimaryColor});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late Future<Map<String, dynamic>> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeather();
  }

  Future<Map<String, dynamic>> _fetchWeather() async {
    const lat = 28.6139; 
    const lon = 77.2090;
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$openWeatherApiKey&units=metric';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather');
    }
  }

  IconData _getWeatherIcon(String mainCondition) {
    switch (mainCondition.toLowerCase()) {
      case 'clear': return Icons.wb_sunny;
      case 'clouds': return Icons.cloud;
      case 'rain': return Icons.grain;
      case 'haze': return Icons.filter_drama;
      default: return Icons.cloud_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return const Card(child: Center(child: Icon(Icons.error, color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Card(child: Center(child: Text('No data')));
        }

        final data = snapshot.data!;
        final temp = data['main']['temp'].toInt();
        final mainCondition = data['weather'][0]['main'];
        
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [widget.primaryColor, widget.darkPrimaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getWeatherIcon(mainCondition), color: Colors.white),
                      const SizedBox(width: 8),
                      Text(mainCondition.toUpperCase(), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const Spacer(),
                  Text('$temp°', style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  Text('TODAY', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final String? waqiApiKey=dotenv.env['waqiApiKey'];

class AqiCard extends StatefulWidget {
  const AqiCard({super.key});

  @override
  State<AqiCard> createState() => _AqiCardState();
}

class _AqiCardState extends State<AqiCard> {
  late Future<Map<String, dynamic>> _aqiFuture;

  @override
  void initState() {
    super.initState();
    _aqiFuture = _fetchAqi();
  }

  Future<Map<String, dynamic>> _fetchAqi() async {
    const city = 'delhi';
    final url = 'https://api.waqi.info/feed/$city/?token=$waqiApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load AQI');
    }
  }

  Map<String, dynamic> _getAqiDetails(int aqi) {
    if (aqi <= 50) return {'level': 'Good', 'colors': [Colors.green, Colors.lightGreen]};
    if (aqi <= 100) return {'level': 'Moderate', 'colors': [Colors.yellow, Colors.amber]};
    if (aqi <= 150) return {'level': 'Unhealthy\nfor some', 'colors': [Colors.orange, Colors.deepOrangeAccent]};
    if (aqi <= 200) return {'level': 'Unhealthy', 'colors': [Colors.red, Colors.redAccent]};
    if (aqi <= 300) return {'level': 'Very\nUnhealthy', 'colors': [Colors.purple, Colors.deepPurpleAccent]};
    return {'level': 'Hazardous', 'colors': [Colors.brown, const Color(0xFF4E342E)]};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _aqiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return const Card(child: Center(child: Icon(Icons.error, color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!['data'] == null) {
          return const Card(child: Center(child: Text('No data')));
        }
        
        final aqi = snapshot.data!['data']['aqi'] as int;
        final aqiDetails = _getAqiDetails(aqi);

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: aqiDetails['colors'],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delhi AQI', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  Row(
                    children: [
                      Text('$aqi', style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          aqiDetails['level'],
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TrafficCard extends StatelessWidget {
  const TrafficCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Traffic Congestion', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Expanded(
              child: Center(child: Icon(Icons.traffic, color: Colors.red, size: 50)),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({super.key});
  
  String _formatEmail(String email) {
    return email.split('@')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Citizen Leaderboard', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('issues').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No reports yet.'));
                  }

                  var reportCounts = <String, int>{};
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final reporter = data['reportedBy'] as String?;
                    if (reporter != null) {
                      reportCounts[reporter] = (reportCounts[reporter] ?? 0) + 1;
                    }
                  }

                  var sortedReporters = reportCounts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  
                  final top3 = sortedReporters.take(3).toList();

                  // --- UPDATED: The whole card is now tappable ---
                  return InkWell(
                    onTap: () {
                      if (top3.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => LeaderboardDialog(topReporters: top3),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: (top3.length > 1) 
                            ? _buildLeaderboardItem(_formatEmail(top3[1].key), '2', const Color(0xFFC0C0C0))
                            : const SizedBox(),
                        ),
                        Expanded(
                          child: (top3.isNotEmpty) 
                            ? _buildLeaderboardItem(_formatEmail(top3[0].key), '1', const Color(0xFFFFD700))
                            : const SizedBox(),
                        ),
                        Expanded(
                          child: (top3.length > 2)
                            ? _buildLeaderboardItem(_formatEmail(top3[2].key), '3', const Color(0xFFCD7F32))
                            : const SizedBox(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(String name, String rank, Color color) {
    double height = rank == '1' ? 60 : (rank == '2' ? 45 : 30); 
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          name,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          width: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              rank,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}


// --- NEW: A dialog widget to show the full leaderboard ---
class LeaderboardDialog extends StatelessWidget {
  final List<MapEntry<String, int>> topReporters;

  const LeaderboardDialog({super.key, required this.topReporters});

  Widget _getMedalForRank(int rank) {
    switch (rank) {
      case 1:
        return const Text('🥇', style: TextStyle(fontSize: 24));
      case 2:
        return const Text('🥈', style: TextStyle(fontSize: 24));
      case 3:
        return const Text('🥉', style: TextStyle(fontSize: 24));
      default:
        return Text('#$rank', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Citizen Leaderboard'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: topReporters.length,
          itemBuilder: (context, index) {
            final reporter = topReporters[index];
            return ListTile(
              leading: _getMedalForRank(index + 1),
              title: Text(
                reporter.key, // Show full email/name
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Text(
                '${reporter.value} reports',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}