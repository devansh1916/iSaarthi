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
    const Color primaryColor = Color(0xFF4DB6AC);
    const Color darkPrimaryColor = Color(0xFF00796B);

    return Scaffold(
      backgroundColor: primaryColor,
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
                  DashboardAnimatedBackground(primaryColor: primaryColor, darkPrimaryColor: darkPrimaryColor),
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
                              color: Color(0xFFE8F5E9),
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
                        color: darkPrimaryColor,
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
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
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
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
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
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // --- UPDATED CODE BLOCK ---
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
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              _showErrorSnackBar('The password provided is too weak. Please use at least 6 characters.');
                            } else if (e.code == 'email-already-in-use') {
                              _showErrorSnackBar('An account already exists for that email.');
                            } else if (e.code == 'invalid-email') {
                              _showErrorSnackBar('The email address is not valid.');
                            } else {
                              _showErrorSnackBar('An error occurred. Please try again.');
                            }
                          }
                        },
                        // --- END OF UPDATED CODE BLOCK ---
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkPrimaryColor,
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
                              color: darkPrimaryColor,
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

  // --- NEW HELPER METHOD ---
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}


class DashboardAnimatedBackground extends StatefulWidget {
  final Color primaryColor;
  final Color darkPrimaryColor;
  const DashboardAnimatedBackground({super.key, required this.primaryColor, required this.darkPrimaryColor});

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
