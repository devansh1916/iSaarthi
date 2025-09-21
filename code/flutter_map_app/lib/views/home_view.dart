import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'report_choose.dart';
import '../widgets/nav_bar.dart';
import 'dart:math';
import 'issue_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to log out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Log Out'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  // Navigate to the login screen and clear the navigation stack
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Helper to build the status indicator
  Widget _buildStatusIndicator(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'resolved':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'in progress':
        color = Colors.orange;
        icon = Icons.hourglass_top_outlined;
        break;
      default: // Pending
        color = Colors.grey.shade600;
        icon = Icons.pending_outlined;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // --- UPDATED: This widget is now styled to match the explore view card ---
  Widget _buildIssueCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => IssueDetailView(issueId: doc.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? 'No Title',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'] ?? 'No description available.',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildStatusIndicator(data['status'] ?? 'Pending'),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the entire "Your Issues" section
  Widget _buildUserIssuesSection() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Reported Issues',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00796B)),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('issues')
                .where('reportedBy', isEqualTo: user.email)
                .orderBy('timestamp', descending: true)
                .limit(5) // Show the 5 most recent issues
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('You have not reported any issues yet.'),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) => _buildIssueCard(doc)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4DB6AC);
    const Color darkPrimaryColor = Color(0xFF00796B);

    return Scaffold(
      backgroundColor: primaryColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: false,
            floating: false,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  const DashboardAnimatedBackground(primaryColor: primaryColor, darkPrimaryColor: darkPrimaryColor),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Hello User!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                              SizedBox(height: 4),
                              Text('South Delhi', style: TextStyle(fontSize: 16, color: Color(0xFFE8F5E9), fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _showLogoutDialog,
                            child: Stack(
                              children: [
                                const CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person, color: primaryColor, size: 40),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.fromBorderSide(
                                        const BorderSide(color: Colors.white, width: 2.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 30.0, 24.0, 8.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Q Search',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ReportChooserView()),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.orange.withOpacity(0.3), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Center(
                          child: Text('Start Reporting', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Issue Resolution Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkPrimaryColor)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: const BarChartWidget(primaryColor: primaryColor, darkPrimaryColor: darkPrimaryColor),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: const CircularProgressWidget(primaryColor: primaryColor, darkPrimaryColor: darkPrimaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      children: [
                        Expanded(child: _buildStatCard('22,495', 'Reports in past week', const Color(0xFFFF9800))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('48,443', 'Fixed in past month', primaryColor)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('12,730,573', 'Updates on reports', const Color(0xFFE0E0E0))),
                      ],
                    ),
                  ),
                  _buildUserIssuesSection(),
                  const SizedBox(height: 100),
                ],
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
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildStatCard(String number, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// Your original custom widgets are preserved below
class DashboardAnimatedBackground extends StatefulWidget {
  final Color primaryColor;
  final Color darkPrimaryColor;
  const DashboardAnimatedBackground({super.key, required this.primaryColor, required this.darkPrimaryColor});

  @override
  State<DashboardAnimatedBackground> createState() => _DashboardAnimatedBackgroundState();
}

class _DashboardAnimatedBackgroundState extends State<DashboardAnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(duration: const Duration(seconds: 20), vsync: this)..repeat();
    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(_waveController);

    _pulseController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this)..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: Alignment.center,
          child: CustomPaint(
            painter: DashboardBackgroundPainter(_waveAnimation.value, widget.primaryColor, widget.darkPrimaryColor),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class DashboardBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color darkPrimaryColor;
  final Random _random = Random();

  DashboardBackgroundPainter(this.animationValue, this.primaryColor, this.darkPrimaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor,
        primaryColor.withOpacity(0.8),
        primaryColor.withOpacity(0.6),
        primaryColor.withOpacity(0.4),
      ],
    );
    final shader = gradient.createShader(rect);
    paint.shader = shader;
    canvas.drawRect(rect, paint);

    paint.shader = null;
    final shapeColor = darkPrimaryColor;

    paint.color = shapeColor.withOpacity(0.3);
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.3 + (animationValue * 20), size.height * 0.1 + (animationValue * 30),
          size.width * 0.6, size.height * 0.4 + (animationValue * 20))
      ..quadraticBezierTo(size.width * 0.8 + (animationValue * 15), size.height * 0.6 + (animationValue * 25),
          size.width, size.height * 0.5)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path1, paint);

    paint.color = shapeColor.withOpacity(0.4);
    final path2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.2 + (animationValue * 25), size.height * 0.4 + (animationValue * 20),
          size.width * 0.5, size.height * 0.7 + (animationValue * 15))
      ..quadraticBezierTo(size.width * 0.7 + (animationValue * 30), size.height * 0.9 + (animationValue * 10),
          size.width, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path2, paint);

    paint.color = shapeColor.withOpacity(0.2);
    final path3 = Path()
      ..moveTo(size.width * 0.1, size.height)
      ..quadraticBezierTo(size.width * 0.4 + (animationValue * 20), size.height * 0.7 + (animationValue * 25),
          size.width * 0.8, size.height * 0.9 + (animationValue * 15))
      ..quadraticBezierTo(size.width * 0.9 + (animationValue * 10), size.height * 0.6 + (animationValue * 20),
          size.width, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path3, paint);

    final grainPaint = Paint()..color = Colors.black.withOpacity(0.05);
    for (int i = 0; i < 2000; i++) {
      final double x = _random.nextDouble() * size.width;
      final double y = _random.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartWidget extends StatelessWidget {
  final Color primaryColor;
  final Color darkPrimaryColor;
  const BarChartWidget({super.key, required this.primaryColor, required this.darkPrimaryColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Reports',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkPrimaryColor),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBar('Week 1', 0.6, 0.4),
                _buildBar('Week 2', 0.8, 0.5),
                _buildBar('Week 3', 0.7, 0.6),
                _buildBar('Week 4', 0.9, 0.7),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double reportedHeight, double solvedHeight) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 12,
                height: 80 * reportedHeight,
                decoration: BoxDecoration(
                  color: darkPrimaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 12,
                height: 80 * solvedHeight,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}

class CircularProgressWidget extends StatelessWidget {
  final Color primaryColor;
  final Color darkPrimaryColor;
  const CircularProgressWidget({super.key, required this.primaryColor, required this.darkPrimaryColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Progress',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkPrimaryColor),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: 0.75,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
                Text(
                  '75%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkPrimaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}