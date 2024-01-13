// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meals_app/screens/tabs.dart';
import 'package:meals_app/widgets/image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  File? selectedImage;
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  bool isAuthenticating = false;
  void _submit() async {
    var isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLogin && selectedImage == null) {
      return;
    }

    _formKey.currentState!.save();
    try {
      setState(() {
        isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredentials =
            await Future.delayed(const Duration(milliseconds: 700), () {
          _firebase.signInWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);
        });
        Navigator.pushReplacement(context, _createRoute());
        // ignore: avoid_print
        print(userCredentials);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storedImage = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        await storedImage.putFile(selectedImage!);
        final imageUrl = await storedImage.getDownloadURL();
        //  print(imageUrl);
        // ignore: avoid_print
        print(userCredentials);
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'Username': _enteredUsername,
          'email': _enteredEmail,
          'imageUrl': imageUrl
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message.toString(),
            ),
          ),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message.toString(),
            ),
          ),
        );
      }
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  PageRouteBuilder _createRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const TabsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ignore: avoid_unnecessary_containers
                Container(
                  width: 200,
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    left: 30,
                    right: 30,
                  ),
                  child: Image.asset(
                    'assets/images/message.png',
                  ),
                ),
                Card(
                  elevation: 1,
                  //  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomCenter,
                            colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.5),
                        ])),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 16),
                        child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!_isLogin)
                                  ImagePickerWidget(
                                    onPickedImage: (pickedImage) {
                                      selectedImage = pickedImage;
                                    },
                                  ),
                                TextFormField(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: Colors.brown.shade100),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        !value.contains('@') ||
                                        value.trim().length < 6) {
                                      return 'email is invalid';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _enteredEmail = newValue!;
                                  },
                                ),
                                if (!_isLogin)
                                  TextFormField(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: Colors.brown.shade100),
                                    enableSuggestions: false,
                                    //  keyboardType: TextInputType.name,
                                    decoration: const InputDecoration(
                                        labelText: 'Username',
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    autocorrect: false,
                                    textCapitalization: TextCapitalization.none,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty ||
                                          value.trim().length < 4) {
                                        return 'username should be more than 4 characters';
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      _enteredUsername = newValue!;
                                    },
                                  ),
                                TextFormField(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: Colors.brown.shade100),
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 6) {
                                      return 'password must be 6 characters or long';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _enteredPassword = newValue!;
                                  },
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer),
                                    onPressed: _submit,
                                    child: !isAuthenticating
                                        ? Text(
                                            _isLogin ? 'Login' : 'Signup',
                                            style: TextStyle(
                                                color: Colors.brown.shade400,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle),
                                            child:
                                                const CircularProgressIndicator())),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(
                                    _isLogin
                                        ? 'Create an account'
                                        : 'Already have an account',
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
