import 'package:flutter/material.dart';
import 'package:graduation/network/sing-inAPI.dart';

class Singupscreen2 extends StatefulWidget {
  const Singupscreen2({super.key});

  @override
  State<Singupscreen2> createState() => _Singupscreen2State();
}

class _Singupscreen2State extends State<Singupscreen2> {
  bool _obscurePassword = true;
  String _selectedCountry = "EG";

  final AuthApi authApi = AuthApi();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void registerUser() async {
    try {
      setState(() {
        isLoading = true;
      });

      print("🔥 REGISTER START");

      // ✅ Check empty fields
      if (firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          birthdayController.text.isEmpty ||
          phoneController.text.isEmpty) {
        print("❌ Missing fields");
        return;
      }

      // ✅ Safe Date Parsing
      String dateOfBirth;
      try {
        dateOfBirth = DateTime.parse(birthdayController.text)
            .toUtc()
            .toIso8601String();
      } catch (e) {
        print("❌ Invalid date format");
        return;
      }

      // ✅ API CALL (no UI changes)
      final result = await authApi.registerUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phone: "+20${phoneController.text.trim()}",
        dateOfBirth: dateOfBirth,
      );

      print("✅ SUCCESS: $result");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered Successfully")),
      );
    } catch (e, stack) {
      print("❌ ERROR: $e");
      print("❌ STACK: $stack");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E65B4), Colors.white],
              stops: [0.0, 0.09],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),

                const Text(
                  "Register",
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Create an account to continue!",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 30),

                // First Name
                TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Last Name
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Birthday
                TextFormField(
                  controller: birthdayController,
                  decoration: InputDecoration(
                    labelText: "Birthday",
                    hintText: "2004-07-07",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Phone
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    hintText: "113456789",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    prefix: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButton<String>(
                        value: _selectedCountry,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: "EG", child: Text("+20 🇪🇬")),
                          DropdownMenuItem(value: "US", child: Text("+1 🇺🇸")),
                          DropdownMenuItem(value: "UK", child: Text("+44 🇬🇧")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCountry = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
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

                const SizedBox(height: 30),

                // Button (NO UI CHANGE)
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xff0665BC),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: InkWell(
                    onTap: isLoading ? null : registerUser,
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Register",
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(fontSize: 14, color: Color(0xff6C7278)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff4D81E7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}