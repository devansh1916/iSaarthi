import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'views/register_view.dart';
import 'package:firebase_core/firebase_core.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title:"Map app",
    theme:ThemeData(
      primaryColor:Colors.cyanAccent
    ),
    home:const RegisterView()
    ,)
  );
}


class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FullscreenWebView(),
    );
  }
}

class FullscreenWebView extends StatefulWidget {
  const FullscreenWebView({super.key});

  @override
  State<FullscreenWebView> createState() => _FullscreenWebViewState();
}

class _FullscreenWebViewState extends State<FullscreenWebView> {
  late final WebViewController _controller;
  final String url = "https://api.maptiler.com/maps/0197cb4e-5175-7b8e-a05b-7119c556c260/?key=WCthTmHiFHsTzAuLYrKr#1.0/0.00000/0.00000";
  
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}