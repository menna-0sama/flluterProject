import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation/model/profile_model.dart';
import 'package:graduation/screens/forgotpasswordScreen.dart';
import 'package:graduation/screens/Signupscreen.dart';
import 'package:graduation/screens/courses.dart';
import 'package:graduation/network/profile_api.dart';
import 'package:graduation/network/dio_client.dart';
import 'package:graduation/network/logout_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;
  bool isSaving = false;
  bool isUploadingImage = false;

  File? selectedImage;
  String? profileImageUrl;
  String userLevel = "";
  List<ProfileTrackModel> userTracks = [];

  int imageVersion = 0;
  static const String savedProfileImageKey = "saved_profile_image_url";

  final ImagePicker picker = ImagePicker();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  String selectedCountryCode = "+20 🇪🇬";

  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 18;
    if (width < 600) return 24;
    return 30;
  }

  double responsiveFont(BuildContext context, double size) {
    final width = screenWidth(context);
    if (width < 360) return size - 1;
    if (width > 600) return size + 2;
    return size;
  }

  double avatarRadius(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 55;
    if (width < 600) return 65;
    return 72;
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  String getFullImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return "";

    final cleanUrl = url.trim();

    if (cleanUrl.startsWith("http")) {
      return "$cleanUrl?v=$imageVersion";
    }

    final baseUrl = DioClient.dio.options.baseUrl;
    final fullUrl = Uri.parse(baseUrl).resolve(cleanUrl).toString();

    return "$fullUrl?v=$imageVersion";
  }

  String? extractImageUrlFromResponse(dynamic data) {
    if (data is Map) {
      final direct = data["imageUrl"] ??
          data["profileImageUrl"] ??
          data["photoUrl"] ??
          data["url"];

      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString();
      }

      if (data["data"] is Map) {
        final nested = data["data"]["imageUrl"] ??
            data["data"]["profileImageUrl"] ??
            data["data"]["photoUrl"] ??
            data["data"]["url"];

        if (nested != null && nested.toString().trim().isNotEmpty) {
          return nested.toString();
        }
      }
    }

    return null;
  }

  Future<void> loadProfile({bool showLoading = true}) async {
    try {
      if (showLoading) {
        setState(() => isLoading = true);
      }

      final profile = await ProfileApi.getProfile();

      final prefs = await SharedPreferences.getInstance();
      final savedImageUrl = prefs.getString(savedProfileImageKey);

      if (!mounted) return;

      setState(() {
        firstNameController.text = profile.firstName;
        lastNameController.text = profile.lastName;
        emailController.text = profile.email;
        phoneController.text = profile.phone;

        final apiImageUrl = profile.imageUrl;

        profileImageUrl =
        apiImageUrl != null && apiImageUrl.trim().isNotEmpty
            ? apiImageUrl
            : savedImageUrl;

        userLevel = profile.level;
        userTracks = profile.tracks;

        if (profile.dateOfBirth.isNotEmpty) {
          birthdayController.text =
              profile.dateOfBirth.split("T").first;
        }

        isLoading = false;
      });

      print("PROFILE IMAGE URL: $profileImageUrl");
      print("PROFILE LEVEL: $userLevel");
      print("PROFILE TRACKS: ${userTracks.map((e) => e.name).toList()}");
    } catch (e) {
      print("PROFILE ERROR: $e");

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load profile"),
        ),
      );
    }
  }

  Future<void> updateProfile() async {
    setState(() => isSaving = true);

    try {
      await ProfileApi.updateProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        dateOfBirth: birthdayController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      await loadProfile(showLoading: false);
    } catch (e) {
      print("UPDATE PROFILE ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        isUploadingImage = true;
      });

      final uploadResponse = await ProfileApi.uploadImage(selectedImage!);

      final newImageUrl = extractImageUrlFromResponse(uploadResponse);

      imageVersion++;

      if (newImageUrl != null && newImageUrl.trim().isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(savedProfileImageKey, newImageUrl);

        final fullUrl = getFullImageUrl(newImageUrl);
        await NetworkImage(fullUrl).evict();

        if (!mounted) return;

        setState(() {
          profileImageUrl = newImageUrl;
          selectedImage = null;
        });

        print("✅ SAVED PROFILE IMAGE LOCAL: $newImageUrl");
      } else {
        await loadProfile(showLoading: false);

        if (!mounted) return;

        setState(() {
          selectedImage = null;
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully")),
      );
    } catch (e) {
      print("IMAGE UPLOAD ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image")),
      );
    } finally {
      if (mounted) {
        setState(() => isUploadingImage = false);
      }
    }
  }

  Future<void> logout() async {
    try {
      await LogoutApi.logout();
      await DioClient.clearTokens();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Signupscreen()),
            (route) => false,
      );
    } catch (e) {
      print("LOGOUT ERROR: $e");

      await DioClient.clearTokens();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Signupscreen()),
            (route) => false,
      );
    }
  }

  Future<void> confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      logout();
    }
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2004, 7, 17),
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

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? labelText,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(fontSize: responsiveFont(context, 14)),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: screenWidth(context) < 360 ? 13 : 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget buildMainButton({
    required String text,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: screenWidth(context) < 360 ? 48 : 52,
        decoration: BoxDecoration(
          color: const Color(0xff0665BC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
            text,
            style: TextStyle(
              fontSize: responsiveFont(context, 16),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard() {
    final tracksText = userTracks.isEmpty
        ? "No track selected"
        : userTracks.map((track) => track.name).join(", ");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF1F7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffD6E9FF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.route, color: Color(0xff0665BC)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Track: $tracksText",
                  style: TextStyle(
                    fontSize: responsiveFont(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xff0665BC)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Level: ${userLevel.isEmpty ? "Not selected" : userLevel}",
                  style: TextStyle(
                    fontSize: responsiveFont(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPhonePrefix() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text("+20 🇪🇬"),
                    onTap: () {
                      setState(() => selectedCountryCode = "+20 🇪🇬");
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text("+1 🇺🇸"),
                    onTap: () {
                      setState(() => selectedCountryCode = "+1 🇺🇸");
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text("+44 🇬🇧"),
                    onTap: () {
                      setState(() => selectedCountryCode = "+44 🇬🇧");
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth(context) < 360 ? 8 : 12,
          vertical: 15,
        ),
        child: Text(
          selectedCountryCode,
          style: TextStyle(fontSize: responsiveFont(context, 14)),
        ),
      ),
    );
  }

  ImageProvider getAvatarImage() {
    if (selectedImage != null) {
      return FileImage(selectedImage!);
    }

    final fullImageUrl = getFullImageUrl(profileImageUrl);

    if (fullImageUrl.isNotEmpty) {
      return NetworkImage(fullImageUrl);
    }

    return const AssetImage("images/Ilustration - Home Page.png");
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = screenWidth(context);
    final headerHeight = width < 360 ? 340.0 : 390.0;
    final radius = avatarRadius(context);

    final topImageSpace = width < 360
        ? 45.0
        : width < 600
        ? 55.0
        : 70.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: headerHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Rectangle 189.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                isLoading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      SizedBox(height: topImageSpace),

                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: radius,
                              backgroundImage: getAvatarImage(),
                            ),

                            GestureDetector(
                              onTap:
                              isUploadingImage ? null : pickImage,
                              child: Container(
                                padding: EdgeInsets.all(
                                  width < 360 ? 5 : 6,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: isUploadingImage
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: width < 360 ? 24 : 30,
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                          horizontalPadding(context),
                        ),
                        child: Column(
                          children: [
                            buildInfoCard(),
                            const SizedBox(height: 16),

                            buildTextField(
                              controller:
                              firstNameController,
                              hintText: "First Name",
                            ),

                            const SizedBox(height: 16),

                            buildTextField(
                              controller:
                              lastNameController,
                              hintText: "Last Name",
                            ),

                            const SizedBox(height: 16),

                            buildTextField(
                              controller: emailController,
                              hintText: "Email",
                              keyboardType:
                              TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            buildTextField(
                              controller:
                              birthdayController,
                              hintText: "",
                              labelText: "Birthday",
                              readOnly: true,
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.calendar_today,
                                ),
                                onPressed: pickDate,
                              ),
                              onTap: pickDate,
                            ),

                            const SizedBox(height: 16),

                            buildTextField(
                              controller:
                              phoneController,
                              hintText: "Phone",
                              keyboardType:
                              TextInputType.phone,
                              prefixIcon:
                              buildPhonePrefix(),
                            ),

                            const SizedBox(height: 22),

                            buildMainButton(
                              text: "Save Changes",
                              onTap: isSaving
                                  ? null
                                  : updateProfile,
                              loading: isSaving,
                            ),

                            const SizedBox(height: 16),

                            buildMainButton(
                              text: "change password",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const Forgotpasswordscreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 22),

                            buildMainButton(
                              text: "Log Out",
                              onTap: confirmLogout,
                            ),

                            const SizedBox(height: 35),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: goBack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}