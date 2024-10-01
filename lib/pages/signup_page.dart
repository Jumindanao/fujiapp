import 'package:flutter/material.dart';

import 'package:fuji_app/classess/readdata.dart';

import 'package:fuji_app/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  //para sa data passing
  String uid = "";
  String full_name = "";
  String theemail = "";
  //

  Future<void> signUpUser() async {
    //checking sa database ang userID
    final String userID;

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('fields are not filled'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        duration: const Duration(seconds: 3),
      ));
      return;
    }

    try {
      // Step 1: Sign up the user
      final authResponse = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      userID = authResponse.user!.id;
      final Session? session = authResponse.session;
      bool isDone = false;

      if (session != null) {
        await supabase.from('profiles').insert({
          'id': userID,
          'full_name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'therole': 'Student',
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: Text("User signed up: ${authResponse.user!.email!}"),
              actions: [
                TextButton(
                  child: const Text("Ok"),
                  onPressed: () async {
                    isDone = true;
                    if (isDone == true) {
                      final data = await supabase
                          .from('profiles')
                          .select('id,full_name,email')
                          .eq('id', userID);
                      final uid = data[0]['id'];
                      final fullName = data[0]['full_name'];
                      final theemail = data[0]['email'];
                      const therole = 'Student';
                      Navigator.of(context).pushReplacementNamed(
                        '/CoursePage',
                        arguments: Readdata(
                            id: uid,
                            theusername: fullName,
                            theemail: theemail,
                            therole: therole),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text('Failed to sign up: $e'),
            actions: [
              TextButton(
                child: const Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 80.0),
          const Center(
            child: Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40.0),
          const Text(
            "Name",
            style: TextStyle(fontSize: 18.0),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your name',
            ),
          ),
          const SizedBox(height: 20.0),
          const Text(
            "Email",
            style: TextStyle(fontSize: 18.0),
          ),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your email',
            ),
          ),
          const SizedBox(height: 20.0),
          const Text(
            "Password",
            style: TextStyle(fontSize: 18.0),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your password',
            ),
          ),
          const SizedBox(height: 40.0),
          ElevatedButton(
            onPressed: signUpUser,
            child: const Text('Signup'),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
