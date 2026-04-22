import 'package:flutter/material.dart';
import 'package:graduation/screens/sendcodeScreen.dart';

class Forgotpasswordscreen extends StatelessWidget {
  const Forgotpasswordscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ترجع للصفحة اللي قبلها
          },
        ),
      ),

      body:Padding(
        padding: const EdgeInsets.only(left: 30,right: 30),
        child: Column(
          children: [
            SizedBox(height: 30,),
            Align(
              alignment: AlignmentGeometry.topStart,
                child: Text("Forgot password?",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),)),
            SizedBox(height: 20,),
            Align(
                alignment: AlignmentGeometry.topStart,
                child: Text("Don’t worry! It happens. Please enter the \n email associated with your account.",style: TextStyle(fontSize: 16 ,color: Colors.black54),)),
            SizedBox(height: 50,),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Email Address",
                hintText: "Enter Your Email Address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Sendcodescreen(), // الصفحة اللي هتروحي لها
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
                    "Send code",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 400,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Remember password? ",
                  style:
                  TextStyle(fontSize: 14, color: Color(0xff6C7278)),
                ),
                GestureDetector(
                  onTap: () {
                    // اودي الصفحة للـ SignIn
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff4D81E7),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
