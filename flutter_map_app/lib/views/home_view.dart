import 'package:flutter/material.dart';
import 'report_choose.dart';
import '../widgets/nav_bar.dart';
import 'dart:math';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Header with animated background
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
                  const DashboardAnimatedBackground(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hello User!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'South Delhi',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFE8F5E9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Profile picture with online indicator
                          Row(
                            children: [
                              Stack(
                                children: [
                                  const CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      color: Color(0xFF598A73),
                                      size: 30,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(
                                          BorderSide(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
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
          ),
          // Start Reporting Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF9800),
                      Color(0xFFFFB74D),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Start Reporting',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Issue Resolution Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Issue Resolution Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A3D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Bar Chart
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const BarChartWidget(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Progress Indicator
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const CircularProgressWidget(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Statistics Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '22,495',
                      'Reports in past week',
                      const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '48,443',
                      'Fixed in past month',
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '12,730,573',
                      'Updates on reports',
                      const Color(0xFFE0E0E0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
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
        backgroundColor: const Color(0xFF4CAF50),
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
          Text(
            number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Dashboard Animated Background
class DashboardAnimatedBackground extends StatefulWidget {
  const DashboardAnimatedBackground({super.key});

  @override
  State<DashboardAnimatedBackground> createState() => _DashboardAnimatedBackgroundState();
}

class _DashboardAnimatedBackgroundState extends State<DashboardAnimatedBackground>
    with TickerProviderStateMixin {
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
            painter: DashboardBackgroundPainter(_waveAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class DashboardBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random();

  DashboardBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF4CAF50),
        const Color(0xFF66BB6A),
        const Color(0xFF81C784),
        const Color(0xFFA5D6A7),
      ],
    );
    final shader = gradient.createShader(rect);
    paint.shader = shader;
    canvas.drawRect(rect, paint);

    // Draw animated organic shapes
    paint.shader = null;
    final shapeColor = const Color(0xFF2E7D32);

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

    // Add grain effect
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

// Bar Chart Widget
class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Reports',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D5A3D)),
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
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 12,
                height: 80 * solvedHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
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

// Circular Progress Widget
class CircularProgressWidget extends StatelessWidget {
  const CircularProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Progress',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D5A3D)),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                ),
                const Text(
                  '75%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D5A3D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


