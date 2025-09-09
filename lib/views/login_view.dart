import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import '../main.dart';
import 'package:firebase_core/firebase_core.dart';



class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<LoginView> {

late final TextEditingController _email;
late final TextEditingController _password;
  
@override
void initState() {
  _email=TextEditingController();
  _password=TextEditingController();
  super.initState();
}

@override
void dispose() {
  _email.dispose();
  _password.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Login'),
        backgroundColor:Colors.blue
        ,),
        body: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState==ConnectionState.done) {
          return Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                      enableSuggestions:false,
                      autocorrect:false,
                      keyboardType:TextInputType.emailAddress,
                      controller: _email,
                      decoration:  const InputDecoration(
                        hintText:"Enter Email",
                        border:OutlineInputBorder(borderRadius: BorderRadius.zero)
                      )
                    ),
                ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      obscureText:true,
                      enableSuggestions:false,
                      autocorrect:false,
                      controller: _password,
                      decoration: const InputDecoration(
                        hintText:"Enter password",
                        border:OutlineInputBorder(borderRadius: BorderRadius.zero,
                          borderSide:BorderSide(width:0.5))
                      )
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      
                      final email=_email.text;
                      final password=_password.text;
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email,password: password,);
                        Navigator.of(context).push (
                        MaterialPageRoute(
                          builder: (context)=>const MapView())
                      );
                      } 
                      on FirebaseAuthException catch (e) {
                        print('Registration failed: ${e.message}');
                        }
                    },
                    child: const Text("Login")),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).push (
                        MaterialPageRoute(
                          builder: (context)=>const LoginView())
                      );
                    },
                    child: const Text("Not a User?")
                    ),
                    TextButton(
                    onPressed: () async {
                      Navigator.of(context).push (
                        MaterialPageRoute(
                          builder: (context)=>const MapView())
                      );
                    },
                    child: const Text("Go to App directly")
                    ),
                ],
          
          
              )
            ,);
          }
          else if (asyncSnapshot.hasError) {
            return Center(child: Text("Something Went Wrong!"));
          }
          else {
            return Center(child:CircularProgressIndicator());
          }
        }
      )
    );
  }
}