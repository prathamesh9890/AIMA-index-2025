import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tms_app/api_service/splash_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  final String _logoPath = 'assets/images/tms_logo.png';
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

   SplashServices().checkAuthentication(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                height: size.height * 0.38,
                color: const Color(0xFF024A69),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomCurveClipper(),
              child: Container(
                height: size.height * 0.38,
                color: const Color(0xFF333333),
              ),
            ),
          ),

          Positioned(
            left: -size.width * 0.25,
            top: size.height * 0.18,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: const BoxDecoration(
                color: Color(0xFF4A3090),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: -size.width * 0.25,
            top: size.height * 0.18,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: const BoxDecoration(
                color: Color(0xFFF07A1A),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.55,
                  height: size.width * 0.55,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/tms_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                //const SizedBox(height: 10),
              ],
            ),
          ),

          Positioned(
            bottom: size.height * 0.04,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Powered by',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'TechMET IT Solutions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 12,
            left: 8,
            child: Container(width: 6, height: 32, color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.65);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.1,
      size.width,
      size.height * 0.65,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.35);

    path.quadraticBezierTo(
      size.width * 0.5,
      -size.height * 0.4,
      size.width,
      size.height * 0.35,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
