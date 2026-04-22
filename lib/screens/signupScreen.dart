import 'package:flutter/material.dart';
import 'package:graduation/screens/singupScreen2.dart';
import 'package:graduation/screens/forgotpasswordScreen.dart';
import 'package:graduation/screens/homeScreen.dart';
import 'package:graduation/network/sing-inAPI.dart';

import 'package:google_sign_in/google_sign_in.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  bool _obscurePassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // 🔐 LOGIN FUNCTION (زي ما هي)
  void loginUser() async {
    try {
      setState(() {
        isLoading = true;
      });

      print("🔥 LOGIN START");

      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        print("❌ Missing fields");
        return;
      }

      final authApi = AuthApi();

      final result = await authApi.loginUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("✅ LOGIN SUCCESS: $result");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );

    } catch (e) {
      print("❌ ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Failed")),
      );

    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🔵 GOOGLE LOGIN (إضافة فقط بدون لمس UI)
  Future<void> signInWithGoogle() async {
    try {
      print("🔥 GOOGLE LOGIN START");

      final GoogleSignIn googleSignIn = GoogleSignIn();

      final user = await googleSignIn.signIn();

      if (user == null) {
        print("❌ User cancelled login");
        return;
      }

      final auth = await user.authentication;

      final idToken = auth.idToken;

      final api = AuthApi();

      final result = await api.googleLogin(
        idToken: idToken!,
      );

      print("✅ GOOGLE LOGIN SUCCESS: $result");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );

    } catch (e) {
      print("❌ GOOGLE ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0E65B4),
                Colors.white,
              ],
              stops: [0.0, 0.09],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 120),

                Text(
                  "Sign in to your \nAccount",
                  style: TextStyle(fontSize: 37, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                Text(
                  "Enter your email and password to log in",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                SizedBox(height: 30),

                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "example@gmail.com",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                SizedBox(height: 30),

                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Forgotpasswordscreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff4D81E7),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40),

                GestureDetector(
                  onTap: isLoading ? null : loginUser,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(0xff0665BC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(child: Divider()),
                    Text(" OR "),
                    Expanded(child: Divider()),
                  ],
                ),

                SizedBox(height: 30),

                // 🔵 Google (مربوط الآن)
                GestureDetector(
                  onTap: signInWithGoogle,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(0xffEFF0F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("images/google.png", width: 24),
                        SizedBox(width: 10),
                        Text("Continue with Google"),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xffEFF0F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("images/2021_Facebook_icon 1.png", width: 24),
                      SizedBox(width: 10),
                      Text("Continue with Facebook"),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don’t have an account?"),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Singupscreen2(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xff4D81E7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}