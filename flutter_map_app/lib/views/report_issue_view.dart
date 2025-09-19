import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

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

  final List<String> _departments = [
    'Public Works', 'Utilities', 'Sanitation', 'Parks & Recreation', 
    'Emergency Services', 'Road', 'Water Works'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _locationController = TextEditingController(text: widget.initialLocation);

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
        "issue": _titleController.text,
        "department": _selectedDepartment,
        "location": _locationController.text,
        "description": _descriptionController.text,
        "reportedBy": user.email ?? 'Anonymous'
      };
      
      final url = Uri.parse('http://10.0.2.2:3001/api/issues');

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
          throw Exception('Failed to submit issue. Status code: ${response.statusCode}');
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
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., Near City Hall, Dwarka-21',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
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
