import 'package:flutter/material.dart';
import 'package:graduation/screens/passwordchangeScreen.dart';
class Resetpasswardscreen extends StatefulWidget {
  const Resetpasswardscreen({super.key});

  @override
  State<Resetpasswardscreen> createState() => _ResetpasswardscreenState();
}

class _ResetpasswardscreenState extends State<Resetpasswardscreen> {
  bool _obscurePassword = true; // 👈 تعريف المتغير

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Column(
          children: [
            SizedBox(height: 40),
            Align(
              alignment: AlignmentGeometry.topStart,
              child: Text(
                "Reset password",
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 15),
            Align(
              alignment: AlignmentGeometry.topStart,
              child: Text(
                "Please type something you’ll remember",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            SizedBox(height: 35),
            TextFormField(
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "New Password",
                hintText: "must be 8 characters",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 35),
            TextFormField(
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                hintText: "repeat password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 35),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Passwordchangescreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xff0665BC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Reset password",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}