import 'package:flutter/material.dart';
import 'package:graduation/screens/levelScreen.dart';
import 'package:graduation/model/trak-model.dart';
import 'package:graduation/network/trak-API.dart';
import 'package:graduation/screens/admin_screen.dart';
import 'package:graduation/network/dio_client.dart';
import 'package:graduation/network/profile_api.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  bool isLoading = true;
  List<TrackModel> tracks = [];
  String userName = "";

  @override
  void initState() {
    super.initState();
    loadTracks();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      final profile = await ProfileApi.getProfile();
      if (!mounted) return;
      setState(() => userName = profile.firstName);
    } catch (e) {
      print("GET USER ERROR: $e");
    }
  }

  Future<void> loadTracks() async {
    try {
      final result = await TracksApi.getTracks();
      if (!mounted) return;
      setState(() {
        tracks = result;
        isLoading = false;
      });
    } catch (e) {
      print("TRACKS ERROR: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  String getTrackImage(int index) {
    return index == 0 ? "images/img_1.png" : "images/img.png";
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isSmall = height < 750;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: isSmall ? 380 : 452,
            child: Image.asset(
              "images/Rectangle 189.png",
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: isSmall ? 40 : 60,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hi, ${userName.isEmpty ? "User" : userName}!",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Lets get started with\n your journey",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              "images/Ilustration - Home Page.png",
                              width: isSmall ? 150 : 201,
                              height: isSmall ? 135 : 178,
                            ),
                          ],
                        ),

                        SizedBox(height: isSmall ? 25 : 40),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Choose your track",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text("Ready to Craft Your Code? let's start"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: isLoading
                              ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                              : tracks.isEmpty
                              ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text("No tracks found"),
                            ),
                          )
                              : Column(
                            children:
                            List.generate(tracks.length, (index) {
                              final track = tracks[index];

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == tracks.length - 1
                                      ? 0
                                      : 12,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Levelscreen(
                                              trackId: track.id,
                                            ),
                                      ),
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 100,
                                    ),
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(15),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image(
                                            image: AssetImage(
                                              getTrackImage(index),
                                            ),
                                            width: double.infinity,
                                            height:
                                            isSmall ? 115 : null,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          track.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          track.description,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        SizedBox(height: isSmall ? 25 : 40),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,

                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  "images/Reddit (1).png",
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
                                  "Let me know your goal, and I’ll guide you to the right lessons",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        if (DioClient.isAdmin())
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const AdminScreen(),
                                ),
                              );
                            },
                            child: const Text("Open Admin Panel"),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}