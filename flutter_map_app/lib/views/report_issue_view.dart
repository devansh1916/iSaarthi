import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final API_URL=dotenv.env['NODE_API_URL'];

class ReportIssueView extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final String? initialLocation;
  final String? initialDepartment;

  const ReportIssueView({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialLocation,
    this.initialDepartment,
  });

  @override
  State<ReportIssueView> createState() => _ReportIssueViewState();
}

class _ReportIssueViewState extends State<ReportIssueView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  String? _selectedDepartment;
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;

  final List<String> _departments = [
    'Public Works', 'Utilities', 'Sanitation', 'Parks & Recreation', 
    'Emergency Services', 'Road', 'Water Works'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _locationController = TextEditingController(); 

    if (widget.initialLocation != null) {
      _handleInitialLocation(widget.initialLocation!);
    }

    if (widget.initialDepartment != null && _departments.contains(widget.initialDepartment)) {
      _selectedDepartment = widget.initialDepartment;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleInitialLocation(String location) async {

    if (location.contains(',')) {
      try {
        final parts = location.split(',');
        final lat = double.parse(parts[0].trim());
        final lon = double.parse(parts[1].trim());

        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final address = '${placemark.street}, ${placemark.locality}, ${placemark.postalCode}';
          _locationController.text = address;
        } else {
           _locationController.text = location; 
        }
      } catch (e) {
        print("Error parsing or geocoding initial location: $e");
        _locationController.text = location; 
      }
    } else {

      _locationController.text = location;
    }
  }


  Future<void> _getCurrentLocation() async {
    setState(() { _isFetchingLocation = true; });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
        setState(() { _isFetchingLocation = false; });
        return;
      }
      
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
          setState(() { _isFetchingLocation = false; });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
        setState(() { _isFetchingLocation = false; });
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}';
        _locationController.text = address;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      setState(() { _isFetchingLocation = false; });
    }
  }

  Future<void> _submitIssue() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isSubmitting = true; });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to report an issue.')),
        );
        setState(() { _isSubmitting = false; });
        return;
      }

      final issueData = {
        "title": _titleController.text,
        "department": _selectedDepartment,
        "location": _locationController.text, 
        "description": _descriptionController.text,
        "reportedBy": user.email ?? 'Anonymous'
      };
      

      final url = Uri.parse('$API_URL/api/issues');

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(issueData),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Issue reported successfully!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          final errorBody = jsonDecode(response.body);
          throw Exception('Failed to submit issue: ${errorBody['error']}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() { _isSubmitting = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Submit Issue'),
        backgroundColor: const Color(0xFF55AD9B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (widget.initialTitle != null)
                   Padding(
                     padding: const EdgeInsets.only(bottom: 24.0),
                     child: Text(
                       'AI has pre-filled the form. Please review and edit if necessary.',
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green[800]),
                       textAlign: TextAlign.center,
                     ),
                   ),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Issue Title',
                    hintText: 'e.g., Pothole on Main Street',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title.' : null,
                ),
                const SizedBox(height: 16.0),

                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  hint: const Text('Select the relevant department'),
                  isExpanded: true,
                  items: _departments.map((String department) {
                    return DropdownMenuItem<String>(value: department, child: Text(department));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() { _selectedDepartment = newValue; });
                  },
                  validator: (value) => (value == null) ? 'Please select a department.' : null,
                ),
                const SizedBox(height: 16.0),
                
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., Near City Hall, Dwarka-21',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on),

                    suffixIcon: widget.initialLocation == null 
                      ? (_isFetchingLocation 
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.my_location),
                              onPressed: _getCurrentLocation,
                              tooltip: 'Use Current Location',
                            ))
                      : null,
                  ),
                   validator: (value) => (value == null || value.isEmpty) ? 'Please provide a location.' : null,
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Provide a detailed description of the issue.',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 5,
                   validator: (value) => (value == null || value.isEmpty) ? 'Please describe the issue.' : null,
                ),
                const SizedBox(height: 32.0),

                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitIssue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF55AD9B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : const Text('Confirm & Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}