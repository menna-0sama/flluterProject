import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graduation/provider/auth_provider.dart';
import 'package:graduation/screens/verify_email_screen.dart';
import 'package:provider/provider.dart';

class Singupscreen2 extends StatefulWidget {
  const Singupscreen2({super.key});

  @override
  State<Singupscreen2> createState() => _Singupscreen2State();
}

class _Singupscreen2State extends State<Singupscreen2> {
  bool _obscurePassword = true;
  String _selectedCountry = "EG";

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> pickBirthdayDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2004, 7, 7),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        birthdayController.text =
        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);
  }

  String getCleanPhone() {
    String phone = phoneController.text.trim();

    phone = phone.replaceAll(" ", "");
    phone = phone.replaceAll("-", "");

    if (phone.startsWith("+20")) {
      phone = phone.substring(3);
    }

    if (phone.startsWith("20")) {
      phone = phone.substring(2);
    }

    return phone;
  }

  String getBackendErrorMessage(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;

      print("SERVER ERROR DATA: $data");

      if (data is Map) {
        if (data["errors"] is Map) {
          final errors = data["errors"] as Map;

          List<String> messages = [];

          for (final key in errors.keys) {
            final value = errors[key];

            if (value is List && value.isNotEmpty) {
              messages.addAll(value.map((e) => e.toString()));
            } else if (value != null && value.toString().trim().isNotEmpty) {
              messages.add(value.toString());
            }
          }

          if (messages.isNotEmpty) {
            return messages.join("\n");
          }
        }

        final message = data["message"];
        final errorMessage = data["error"];
        final title = data["title"];

        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }

        if (errorMessage != null && errorMessage.toString().trim().isNotEmpty) {
          return errorMessage.toString();
        }

        if (title != null && title.toString().trim().isNotEmpty) {
          return title.toString();
        }
      }

      if (data != null && data.toString().trim().isNotEmpty) {
        return data.toString();
      }
    }

    return "Registration failed. Please check your data";
  }

  String extractResultErrorMessage(dynamic result) {
    if (result is Map) {
      if (result["errors"] is Map) {
        final errors = result["errors"] as Map;

        List<String> messages = [];

        for (final key in errors.keys) {
          final value = errors[key];

          if (value is List && value.isNotEmpty) {
            messages.addAll(value.map((e) => e.toString()));
          } else if (value != null && value.toString().trim().isNotEmpty) {
            messages.add(value.toString());
          }
        }

        if (messages.isNotEmpty) {
          return messages.join("\n");
        }
      }

      if (result["message"] != null &&
          result["message"].toString().trim().isNotEmpty) {
        return result["message"].toString();
      }

      if (result["title"] != null &&
          result["title"].toString().trim().isNotEmpty) {
        return result["title"].toString();
      }

      if (result["error"] != null &&
          result["error"].toString().trim().isNotEmpty) {
        return result["error"].toString();
      }
    }

    return "Registration failed. Please check your data";
  }

  void registerUser() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final birthday = birthdayController.text.trim();
    final phone = getCleanPhone();

    if (firstName.isEmpty) {
      showMessage("Please enter your first name");
      return;
    }

    if (lastName.isEmpty) {
      showMessage("Please enter your last name");
      return;
    }

    if (email.isEmpty) {
      showMessage("Please enter your email");
      return;
    }

    if (!isValidEmail(email)) {
      showMessage("Please enter a valid email");
      return;
    }

    if (birthday.isEmpty) {
      showMessage("Please select your birthday");
      return;
    }

    final birthdayRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    if (!birthdayRegex.hasMatch(birthday)) {
      showMessage("Birthday must be like this: 2004-07-07");
      return;
    }

    try {
      final parsedBirthday = DateTime.parse(birthday);

      if (parsedBirthday.isAfter(DateTime.now())) {
        showMessage("Birthday cannot be in the future");
        return;
      }
    } catch (e) {
      showMessage("Please enter a valid birthday");
      return;
    }

    if (phone.isEmpty) {
      showMessage("Please enter your phone number");
      return;
    }

    if (!phone.startsWith("01")) {
      showMessage("Phone number must start with 01");
      return;
    }

    if (phone.length != 11) {
      showMessage("Phone number must be 11 digits");
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      showMessage("Phone number must contain numbers only");
      return;
    }

    if (password.isEmpty) {
      showMessage("Please enter your password");
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final result = await authProvider.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        dateOfBirth: birthday,
      );

      print("REGISTER RESULT: $result");

      if (result is Map) {
        final success = result["success"];
        final status = result["status"];
        final statusCode = result["statusCode"];

        if (success == false ||
            status == 400 ||
            status == 500 ||
            statusCode == 400 ||
            statusCode == 500 ||
            result["errors"] != null) {
          showMessage(extractResultErrorMessage(result));
          return;
        }
      }

      showMessage("Verification code sent to your email");

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyEmailScreen(
            email: email,
          ),
        ),
      );
    } catch (e, stack) {
      print("❌ ERROR: $e");
      print("❌ STACK: $stack");

      showMessage(getBackendErrorMessage(e));
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    birthdayController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    required double height,
    String? hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final isSmall = height < 700;
    final horizontalPadding = width * 0.075;
    final topSpace = isSmall ? height * 0.05 : height * 0.10;
    final titleSize = isSmall ? 32.0 : 38.0;
    final fieldHeight = isSmall ? 52.0 : 56.0;
    final fieldSpace = isSmall ? 14.0 : 20.0;
    final buttonHeight = isSmall ? 52.0 : 56.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
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
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: topSpace),
                      Text(
                        "Register",
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmall ? 10 : 15),
                      const Text(
                        "Create an account to continue!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: isSmall ? 18 : 30),
                      buildField(
                        controller: firstNameController,
                        label: "First Name",
                        height: fieldHeight,
                      ),
                      SizedBox(height: fieldSpace),
                      buildField(
                        controller: lastNameController,
                        label: "Last Name",
                        height: fieldHeight,
                      ),
                      SizedBox(height: fieldSpace),
                      buildField(
                        controller: emailController,
                        label: "Email",
                        height: fieldHeight,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: fieldSpace),
                      buildField(
                        controller: birthdayController,
                        label: "Birthday",
                        hint: "Select your birthday",
                        height: fieldHeight,
                        readOnly: true,
                        onTap: pickBirthdayDate,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: pickBirthdayDate,
                        ),
                      ),
                      SizedBox(height: fieldSpace),
                      SizedBox(
                        height: fieldHeight,
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Phone Number",
                            hintText: "01123456789",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: DropdownButton<String>(
                                value: _selectedCountry,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                    value: "EG",
                                    child: Text("+20 🇪🇬"),
                                  ),
                                  DropdownMenuItem(
                                    value: "US",
                                    child: Text("+1 🇺🇸"),
                                  ),
                                  DropdownMenuItem(
                                    value: "UK",
                                    child: Text("+44 🇬🇧"),
                                  ),
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
                      ),
                      SizedBox(height: fieldSpace),
                      SizedBox(
                        height: fieldHeight,
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Enter your Password",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
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
                      ),
                      SizedBox(height: isSmall ? 20 : 30),
                      Container(
                        width: double.infinity,
                        height: buttonHeight,
                        decoration: const BoxDecoration(
                          color: Color(0xff0665BC),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: InkWell(
                          onTap: authProvider.isLoading ? null : registerUser,
                          child: Center(
                            child: authProvider.isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmall ? 16 : 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Flexible(
                            child: Text(
                              "Already have an account? ",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff6C7278),
                              ),
                            ),
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
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}