// lib/views/register_view.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:map_app/views/home_view.dart';
import 'dart:math';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _fullName;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _fullName = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CHANGED: Set the background color to match the new login header.
      backgroundColor: const Color(0xFF3E5C5C),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: false,
            floating: false,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  AnimatedBackground(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hello!',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Welcome to Dashboard',
                            style: TextStyle(
                              fontSize: 18,
                              // CHANGED: Using a lighter, muted color for contrast.
                              color: Color(0xFFC2D1D1),
                              fontWeight: FontWeight.w500,
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
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF598A73),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _fullName,
                      decoration: InputDecoration(
                        hintText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF598A73), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF598A73), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF598A73), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: _email.text,
                              password: _password.text,
                            );
                            await userCredential.user?.updateDisplayName(_fullName.text);
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const HomeView()),
                                (route) => false,
                              );
                            }
                          } on FirebaseAuthException {
                            // Handle errors
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF598A73),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Or sign with', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        ),
                        Expanded(child: Container(height: 1, color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(Icons.facebook, const Color(0xFF1877F2)),
                        const SizedBox(width: 16),
                        _buildSocialButton(Icons.g_mobiledata, Colors.white, borderColor: Colors.grey),
                        const SizedBox(width: 16),
                        _buildSocialButton(Icons.apple, Colors.black),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF598A73),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color backgroundColor, {Color? borderColor}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
      ),
      child: Icon(icon, color: backgroundColor == Colors.white ? Colors.black : Colors.white, size: 24),
    );
  }
}

// CHANGED: Replaced with the new Background painter for consistency.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 20), vsync: this)..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(painter: BackgroundPainter(_animation.value), size: Size.infinite);
        });
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random();

  BackgroundPainter(this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create new darker gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF3E5C5C), // Darker, muted teal
        const Color(0xFF5C8282), // Lighter complementary color
      ],
    );
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw animated organic shapes with new colors
    paint.shader = null;
    final shapeColor1 = const Color(0xFF4A6B6B);
    final shapeColor2 = const Color(0xFF3E5C5C);

    // Shape 1
    paint.color = shapeColor1.withOpacity(0.7);
    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.quadraticBezierTo(size.width * 0.3 + (animationValue * 20), size.height * 0.1 + (animationValue * 30),
        size.width * 0.6, size.height * 0.4 + (animationValue * 20));
    path1.quadraticBezierTo(size.width * 0.8 + (animationValue * 15), size.height * 0.6 + (animationValue * 25), size.width,
        size.height * 0.5);
    path1.lineTo(size.width, 0);
    path1.close();
    canvas.drawPath(path1, paint);

    // Shape 2
    paint.color = shapeColor2.withOpacity(0.6);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.2 + (animationValue * 25),
      size.height * 0.4 + (animationValue * 20),
      size.width * 0.5,
      size.height * 0.7 + (animationValue * 15),
    );
    path2.quadraticBezierTo(size.width * 0.7 + (animationValue * 30), size.height * 0.9 + (animationValue * 10), size.width,
        size.height * 0.8);
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint);

    // Shape 3
    paint.color = shapeColor1.withOpacity(0.5);
    final path3 = Path();
    path3.moveTo(size.width * 0.1, size.height);
    path3.quadraticBezierTo(size.width * 0.4 + (animationValue * 20), size.height * 0.7 + (animationValue * 25),
        size.width * 0.8, size.height * 0.9 + (animationValue * 15));
    path3.quadraticBezierTo(size.width * 0.9 + (animationValue * 10), size.height * 0.6 + (animationValue * 20), size.width,
        size.height * 0.8);
    path3.lineTo(size.width, size.height);
    path3.close();
    canvas.drawPath(path3, paint);

    // ADDED: Grain effect
    final grainPaint = Paint()..color = Colors.white.withOpacity(0.04);
    for (int i = 0; i < 3000; i++) {
      final double x = _random.nextDouble() * size.width;
      final double y = _random.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}