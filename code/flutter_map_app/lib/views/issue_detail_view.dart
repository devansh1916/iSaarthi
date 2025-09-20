import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class IssueDetailView extends StatefulWidget {
  final String issueId;
  const IssueDetailView({required this.issueId, super.key});

  @override
  State<IssueDetailView> createState() => _IssueDetailViewState();
}

class _IssueDetailViewState extends State<IssueDetailView> {
  Map<String, dynamic>? _issueData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIssueDetails();
  }

  Future<void> _fetchIssueDetails() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('issues').doc(widget.issueId).get();
      if (doc.exists && mounted) {
        setState(() {
          _issueData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      print("Error fetching issue details: $e");
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _issueData == null
              ? const Center(child: Text('Issue not found.'))
              : _buildDetailsContent(),
    );
  }

  Widget _buildDetailsContent() {
    final data = _issueData!;
    final timestamp = data['timestamp'] as Timestamp?;
    final priority = data['priority'] ?? 'N/A';
    final status = data['status'] ?? 'Pending';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['title'] ?? 'No Title', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusIndicator(status),
              const Spacer(),
              if (timestamp != null)
                Text(
                  'Reported ${timeago.format(timestamp.toDate())}',
                  style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
                ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow(Icons.description, 'Description', data['description'] ?? 'No description provided.'),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.location_on, 'Location', data['readableLocation'] ?? data['location'] ?? 'No location provided.'),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.business, 'Department', data['department'] ?? 'N/A'),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.priority_high, 'Priority', priority, highlight: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, {bool highlight = false}) {
    Color valueColor;
    switch (value.toLowerCase()) {
      case 'high': valueColor = Colors.red.shade700; break;
      case 'medium': valueColor = Colors.orange.shade800; break;
      case 'low': valueColor = Colors.blue.shade700; break;
      default: valueColor = Colors.black87;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[500], size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: highlight ? valueColor : Colors.black87,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildStatusIndicator(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'resolved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'in progress':
        color = Colors.orange;
        icon = Icons.hourglass_top;
        break;
      default: 
        color = Colors.grey;
        icon = Icons.pending;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}