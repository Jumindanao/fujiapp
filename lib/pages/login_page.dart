import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import "package:fuji_app/classess/readdata.dart";

final supabase = Supabase.instance.client;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future signIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    final email = emailController.text;
    final password = passwordController.text;
    final String userID;

    if (email.isEmpty || password.isEmpty) {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields")),
      );
      return;
    }

    try {
      final AuthResponse authResponse = await supabase.auth
          .signInWithPassword(email: email, password: password);

      userID = authResponse.user!.id;
      final Session? session = authResponse.session;
      // Checking na sa mga needed data and getting the ID for reference para ma
      //get and data
      if (session != null) {
        final data = await supabase
            .from('profiles')
            .select('id,full_name,email,therole,Privacy')
            .eq('id', userID);
        // gi load na ang data para ma gamit na sa next widget or screen
        final String uid = data[0]['id'];
        final String fullName = data[0]['full_name'];
        final String email = data[0]['email'];
        final String therole = data[0]['therole'];
        final bool isPrivacy = (data[0]['Privacy'] ?? false) as bool;
        Readdata(
            id: uid,
            theusername: fullName,
            theemail: email,
            therole: therole,
            isPrivacy: isPrivacy);

        if (therole == "Sensei") {
          Navigator.of(context).pushReplacementNamed('/AdminCourse',
              arguments: Readdata(
                  id: uid,
                  theusername: fullName,
                  theemail: email,
                  therole: therole,
                  isPrivacy: isPrivacy));
        } else {
          Navigator.of(context).pushReplacementNamed('/CoursePage',
              arguments: Readdata(
                  id: uid,
                  theusername: fullName,
                  theemail: email,
                  therole: therole,
                  isPrivacy: isPrivacy));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed: Invalid credentials")),
        );
      }
    } catch (e) {
      // Catch any errors (like network errors) and show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
      Navigator.of(context).pop();
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
              "Login",
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40.0),
          const Center(
            child: Text(
              "FUJI APP",
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40.0),
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
            onPressed: () {
              signIn();
            },
            child: const Text('Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/signup');
            },
            child: const Text('Signup'),
          ),
        ],
      ),
    );
  }
}
