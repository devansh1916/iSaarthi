import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'login_view.dart';

enum Button {logout,register }




class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

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
      appBar: AppBar(title:Text('Registeration'),
      backgroundColor: Colors.blue,
      actions: <Widget> [
       PopupMenuButton<Button>(
        onSelected:(Button value) {
          switch (value) {
            case Button.logout:
             Navigator.of(context).push (
              MaterialPageRoute(
                builder: (context) => const LoginView()
                )
             );
             default:
             print("Please press a valid button");
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<Button> (
            value: Button.logout,
            child: const Text("Logout")
          )
        ]
       )
        ]
      ),
      body:Center(
        child: Column(
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
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email,password: password,);
                          Navigator.of(context).pushReplacement (
                          MaterialPageRoute(
                            builder: (context)=>const MapView())
                        );
                        } 
                        on FirebaseAuthException catch (e) {
                          print('Registration failed: ${e.message}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Registration Failed,Try again'),
                              backgroundColor: Colors.red,
                              ),
                          );
                          }
                      },
                      child: const Text("Register")),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).push (
                          MaterialPageRoute(
                            builder: (context)=>const LoginView())
                        );
                      },
                      child: const Text("Already a User?")
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
            
            
                ),
      )
            ,);
  }
}


