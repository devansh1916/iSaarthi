import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/widgets/nav_bar.dart';
import 'report_choose.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  _ChatbotViewState createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [
    {
      "role": "bot",
      "content": "Hello! I'm Atharva AI. How can I help you today?",
      "timestamp": "10:30 AM"
    }
  ];
  bool isTyping = false;
  

  static final String pythonModel=dotenv.env['PYTHON_MODEL_URL']!;
  final String backendUrl = "$pythonModel/chatbot";

  final List<String> suggestedActions = [ 
    "Traffic updates",
    "Water schedule", 
    "Power outages",
    "Municipal services",
    "Road conditions",
    "Public transport"
  ];

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      messages.add({
        "role": "user", 
        "content": message,
        "timestamp": _getCurrentTime()
      });
      isTyping = true;
    });
    
    _controller.clear();

    try {
      final url = Uri.parse("$backendUrl?query=${Uri.encodeComponent(message)}");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          messages.add({
            "role": "bot", 
            "content": data["reply"],
            "timestamp": _getCurrentTime()
          });
        });
      } else {
        setState(() {
          messages.add({
            "role": "bot", 
            "content": "⚠️ Error: ${res.statusCode}",
            "timestamp": _getCurrentTime()
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "role": "bot", 
          "content": "⚠️ Failed to reach backend",
          "timestamp": _getCurrentTime()
        });
      });
    } finally {
      setState(() {
        isTyping = false;
      });
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    bool isUser = msg["role"] == "user";
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF20B2AA),
              radius: 16,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
          
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF20B2AA) : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg["content"] ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: isUser ? Colors.white : Colors.black87,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg["timestamp"] ?? "",
                    style: TextStyle(
                      fontSize: 12,
                      color: isUser ? Colors.white70 : Colors.grey[600],
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF20B2AA),
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF20B2AA), 
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atharva',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your AI assistant',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < messages.length) {
                    return _buildMessage(messages[index]);
                  } else {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFF20B2AA),
                            radius: 16,
                            child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF20B2AA)),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Typing...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),

            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: suggestedActions.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: ElevatedButton(
                      onPressed: () {
                        _sendMessage("Tell me about ${suggestedActions[index].toLowerCase()}");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: const Color(0xFF333333),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        suggestedActions[index],
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ask about Delhi's civic services...",
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: 'Inter',
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                      ),
                      onSubmitted: (text) {
                         if (text.trim().isNotEmpty) {
                          _sendMessage(text.trim());
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        _sendMessage(text);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF20B2AA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ReportChooserView()),
          );
        },
        backgroundColor: const Color(0xFF55AD9B),
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3), // Set index to 3 for chatbot
    );
  }
}