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
  bool isChecked = false; // For checkbox state

  //para sa data passing
  String uid = "";
  String full_name = "";
  String theemail = "";
  //

  Future<void> signUpUser() async {
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
        // Step 2: Insert user profile into 'profiles' table
        await supabase.from('profiles').insert({
          'id': userID,
          'full_name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'therole': 'Student',
          'Privacy': isChecked, // Store the checkbox value (isPrivacy)
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
                      // Step 3: Fetch the inserted profile
                      final data = await supabase
                          .from('profiles')
                          .select('id,full_name,email,Privacy')
                          .eq('id', userID);
                      final uid = data[0]['id'];
                      final fullName = data[0]['full_name'];
                      final theemail = data[0]['email'];
                      const therole = 'Student';

                      // Step 4: Navigate to the next page with Readdata
                      Navigator.of(context).pushReplacementNamed(
                        '/CoursePage',
                        arguments: Readdata(
                          id: uid,
                          theusername: fullName,
                          theemail: theemail,
                          therole: therole,
                          isPrivacy: isChecked, // Pass the isPrivacy value
                        ),
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
          const SizedBox(height: 20.0),
          // Checkbox with clickable "Data Privacy Act"
          Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
              ),
              //Data privacy checking
              const Text('I agree to the '),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Data Privacy Act"),
                        content: const Text(
                            "By signing up, you agree to our Data Privacy Act which protects your personal information."),
                        actions: [
                          TextButton(
                            child: const Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'Data Privacy Act',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40.0),
          ElevatedButton(
            onPressed: isChecked
                ? signUpUser
                : null, // Disable button if checkbox is not checked
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
