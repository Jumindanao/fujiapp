import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fuji_app/classess/readdata.dart';

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
      },
    );

    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields")),
      );
      Navigator.of(context).pop(); // Close the CircularProgressIndicator
      return;
    }

    try {
      final AuthResponse authResponse = await supabase.auth
          .signInWithPassword(email: email, password: password);

      final userID = authResponse.user!.id;
      final Session? session = authResponse.session;

      if (session != null) {
        final data = await supabase
            .from('profiles')
            .select('id,full_name,email,therole,Privacy')
            .eq('id', userID);

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
          isPrivacy: isPrivacy,
        );

        Navigator.of(context).pop(); // Close the CircularProgressIndicator
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
        Navigator.of(context).pop(); // Close the CircularProgressIndicator
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Login failed: email or password are incorrect please try again")),
      );
      Navigator.of(context).pop(); // Close the CircularProgressIndicator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allows view to adjust for keyboard
      body: Stack(
        children: [
          // Background Image with Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fuji Logo
                    Image.asset(
                      'assets/fujiLogo.png', // Add your logo image
                      height: 120,
                      width: 120,
                    ),
                    const SizedBox(height: 20),
                    // Login Text
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // App Title
                    const Text(
                      "Fuji App",
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30.0),

                    // Email Input Field
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Input Field
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Login Button
                    ElevatedButton(
                      onPressed: signIn,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 80.0),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Signup Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/signup');
                      },
                      child: const Text(
                        'Don’t have an account? Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
