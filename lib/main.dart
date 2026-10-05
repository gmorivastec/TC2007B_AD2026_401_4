// 1 - install firebase cli
// https://firebase.google.com/docs/cli
// 1a - firebase login (on your terminal)

// 2 - install flutterfire cli
// dart pub global activate flutterfire_cli
// if the command "flutterfire" cannot be found you need to add your dart's pub-cache folder
// to your path 
// IMPORTANT: check the message printed when running "dart pub..."

// 3 - using flutterfire + firebase cli run:
// flutterfire configure --project=your-project

// 4 - install dependencies
// flutter pub add firebase_core
// flutter pub add firebase_auth
// flutter pub add cloud_firestore

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fb/firebase_options.dart';


// FUTURE?!
// (like a promise, but for dart)

Future<void> main() async {

  // step 1 - ensure bindings are working 
  WidgetsFlutterBinding.ensureInitialized();

  // new issue - we need to initialize firebase 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  // we can run the app when firebase is initialized =D 
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Firebase")
        ),
        body: 
        Center(
          child: LoginWidget()
        )
      ),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget>{

  // first thing to add - a couple of objects in charge of tracking 
  // the values of text widgets
  TextEditingController login = TextEditingController();
  TextEditingController password = TextEditingController();
  
  @override
  Widget build(BuildContext context) {

    // suscribe for real time updates
    // DESIGN PATTERN ALERT (QUIZ?)
    // https://en.wikipedia.org/wiki/Singleton_pattern
    // also an observer!!! (listen)
    FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        // ???? 
        // nullable 
        // in null-safe languages you can use '?'
        // to specify a nullable type
        if(user != null) {
          print("****** USER IS AUTHENTICATED: ${user.uid}");
        } else {
          print("***** SIGNED OUT");
        }
      }
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: const InputDecoration(
              border:OutlineInputBorder(),
              labelText: "Login"
            ),
            controller: login
          )
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: const InputDecoration(
              border:OutlineInputBorder(),
              labelText: "Password"
            ),
            controller: password,
            obscureText: true,
          )
        ),
        TextButton(
          onPressed: () async {
            try {
              
              final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: login.text, 
                password: password.text
              );

              print("USER CREATED: ${user.user?.uid}");

            }catch(e) {
              print(e);
            }
          }, 
          child: const Text("Sign up")
        ),
        TextButton(
          onPressed: () async {
              final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: login.text, 
                password: password.text
              );

              print("USER SIGNED in: ${user.user?.uid}");
          }, 
          child: const Text("Sign in")
        ),
        TextButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            print("*** USER SIGNED OUT!");
          }, 
          child: const Text("Sign out")
        ),
        TextButton(
          onPressed: () async {
            
            final puppy = <String,dynamic> {
              "name" : "chucho",
              "breed" : "mixed",
              "age" : 7
            };

            FirebaseFirestore.instance.collection("perritos").add(puppy).then(
              (DocumentReference document){
                print("new doc created: ${document.id}");
              }
            );


          }, 
          child: const Text("Add document")
        ),
        TextButton(
          onPressed: () async {

            FirebaseFirestore.instance.collection("perritos").get().then(
              (QuerySnapshot perritos) {
                print("**********************************");
                for(var currentDoc in perritos.docs) {
                  print("DOCUMENT: ${currentDoc.data()}");
                }  
              }
            );
          }, 
          child: const Text("Query")
        ),
      ],
    );
  }
}