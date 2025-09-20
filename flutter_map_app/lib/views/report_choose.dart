import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'report_issue_view.dart';

class ReportChooserView extends StatefulWidget {
  const ReportChooserView({super.key});

  @override
  State<ReportChooserView> createState() => _ReportChooserViewState();
}

class _ReportChooserViewState extends State<ReportChooserView> {
  bool _isLoading = false;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showLocationServiceDisabledDialog();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _handlePhotoReport() async {
    setState(() { _isLoading = true; });

    try {
      final position = await _determinePosition();
      final locationString = "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}";

      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
      if (pickedFile == null) {
        setState(() { _isLoading = false; });
        return;
      }
      final imageFile = File(pickedFile.path);

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final url = Uri.parse('https://fbc9283a5e4a.ngrok-free.app/api/issues/describe-image');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'imageBase64': base64Image}),
      ).timeout(const Duration(seconds: 20)); 

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ReportIssueView(
            initialTitle: data['title'],
            initialDescription: data['description'],
            initialDepartment: data['department'],
            initialLocation: locationString,
          ),
        ));
      } else {

        throw Exception('Server returned an error: ${response.body}');
      }

    } on TimeoutException catch (_) {

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect to the server. Please check your connection and try again.')),
      );
    } on SocketException catch (_) {

       if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your internet connection.')),
      );
    } catch (e) {

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _showLocationServiceDisabledDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please enable location services to geotag your issue.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handlePhotoReport,
                icon: _isLoading
                    ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Icon(Icons.camera_enhance, size: 28),
                label: const Text('Report with Photo (AI)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF55AD9B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Text("The AI will analyze your photo and location to pre-fill the form for you.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              
              const SizedBox(height: 40),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("OR", style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReportIssueView()));
                },
                icon: const Icon(Icons.edit_note, size: 28),
                label: const Text('Fill Form Manually'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF55AD9B),
                  side: const BorderSide(color: Color(0xFF55AD9B)),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}