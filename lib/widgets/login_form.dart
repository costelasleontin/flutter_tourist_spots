// import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';

//This is a widget integrated in the Settings Screen
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  //The following 2 fields are use to show on IOS info, warning and error messages (snackbar is only supported on Android)
  bool showCupertionMessage = false;
  String cupertinoMessage = '';

  //FirebaseAuth user login function
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (Platform.isIOS) {
        displayCupertinoMessage('Submitting login data');
      } else {
        displaySnackbar('Submitting login data');
      }
      try {
        //The firebase auth login and logof can be move to a provider class if
        //authentication becomes more complex for separation of concerns
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (userCredential.user != null) {
          goToDashboard();
        }
      } on FirebaseAuthException catch (err) {
        if (err.code == 'user-not-found') {
          if (Platform.isIOS) {
            displayCupertinoMessage('No user found for that email.',
                duration: 3);
          } else {
            displaySnackbar('No user found for that email.', duration: 3);
          }
        } else if (err.code == 'wrong-password') {
          if (Platform.isIOS) {
            displayCupertinoMessage('Wrong password provided for that user.',
                duration: 3);
          } else {
            displaySnackbar('Wrong password provided for that user.',
                duration: 3);
          }
        }
      }
    }
  }

  void displaySnackbar(String message, {int duration = 2}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: duration)),
    );
  }

  void displayCupertinoMessage(String message, {int duration = 2}) {
    cupertinoMessage = message;
    setState(() {
      showCupertionMessage = true;
    });
    Future.delayed(Duration(seconds: duration), () {
      cupertinoMessage = '';
      setState(() {
        showCupertionMessage = false;
      });
    });
  }

  void goToDashboard() {
    context.go('/settings/dashboard');
  }

  Widget generateFieldsAndButtons() {
    if (Platform.isIOS) {
      return CupertinoFormSection.insetGrouped(
        header: const Text('Login Form:'),
        children: [
          CupertinoTextFormFieldRow(
            prefix: const Text('Email:'),
            placeholder: '',
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            validator: ValidationBuilder()
                .email('The text isn\'t a valid email')
                .build(),
            onSaved: (newValue) => email = newValue ?? '',
          ),
          CupertinoTextFormFieldRow(
            prefix: const Text('Password:'),
            placeholder: '',
            autocorrect: false,
            obscureText: true,
            validator: ValidationBuilder()
                .minLength(6, 'Password needs to be at least 6 characters long')
                .build(),
            onSaved: (newValue) => password = newValue ?? '',
          ),
          CupertinoButton(onPressed: submitForm, child: const Text('Submit')),
          Text(
            cupertinoMessage,
            style: const TextStyle(color: CupertinoColors.activeOrange),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          TextFormField(
            decoration:
                const InputDecoration(labelText: 'Please input account email'),
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            validator: ValidationBuilder()
                .email('The text isn\'t a valid email')
                .build(),
            onSaved: (newValue) => email = newValue ?? '',
          ),
          TextFormField(
            decoration:
                const InputDecoration(labelText: 'Please input password'),
            autocorrect: false,
            obscureText: true,
            validator: ValidationBuilder()
                .minLength(6, 'Password needs to be at least 6 characters long')
                .build(),
            onSaved: (newValue) => password = newValue ?? '',
          ),
          const SizedBox(height: 15),
          ElevatedButton(onPressed: submitForm, child: const Text('Submit')),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: generateFieldsAndButtons(),
    );
  }
}
