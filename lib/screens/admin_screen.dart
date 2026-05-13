import 'package:flutter/material.dart';
import 'package:graduation/model/admin_user_model.dart';
import 'package:graduation/model/track_stats_model.dart';
import 'package:graduation/network/admin_api.dart';
import 'package:graduation/network/admin_tracks_api.dart';
import 'package:graduation/network/admin_courses_api.dart';
import 'package:graduation/network/admin_dashboard_api.dart';
import 'package:graduation/network/dio_client.dart';
import 'package:graduation/network/logout_api.dart';
import 'package:graduation/screens/lessons_admin_screen.dart';
import 'package:graduation/screens/profile.dart';
import 'package:graduation/screens/signupScreen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  List<AdminUserModel> users = [];
  List<dynamic> tracks = [];
  List<dynamic> courses = [];
  List<TrackStatsModel> dashboardStats = [];

  bool isLoadingUsers = true;
  bool isLoadingTracks = true;
  bool isLoadingCourses = true;
  bool isLoadingDashboard = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);

    loadDashboard();
    loadUsers();
    loadTracks();
    loadCourses();
  }

  Future<void> adminLogout() async {
    try {
      await LogoutApi.logout();
    } catch (e) {
      print("ADMIN LOGOUT ERROR: $e");
    }

    await DioClient.clearTokens();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Signupscreen()),
          (route) => false,
    );
  }

  Widget adminDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xff0665BC),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Admin Panel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pop(context);
              tabController.animateTo(0);
            },
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Users"),
            onTap: () {
              Navigator.pop(context);
              tabController.animateTo(1);
            },
          ),

          ListTile(
            leading: const Icon(Icons.route),
            title: const Text("Tracks"),
            onTap: () {
              Navigator.pop(context);
              tabController.animateTo(2);
            },
          ),

          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text("Courses"),
            onTap: () {
              Navigator.pop(context);
              tabController.animateTo(3);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Profile()),
              );
            },
          ),

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Log Out",
              style: TextStyle(color: Colors.red),
            ),
            onTap: adminLogout,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> loadDashboard() async {
    try {
      final data = await AdminDashboardApi.getTrackStats();
      setState(() {
        dashboardStats = data;
        isLoadingDashboard = false;
      });
    } catch (e) {
      print("DASHBOARD ERROR: $e");
      setState(() => isLoadingDashboard = false);
    }
  }

  Widget dashboardTab() {
    if (isLoadingDashboard) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboardStats.isEmpty) {
      return const Center(child: Text("No dashboard data found"));
    }

    final totalUsers =
    dashboardStats.fold<int>(0, (sum, track) => sum + track.totalUsers);

    return RefreshIndicator(
      onRefresh: loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xff0665BC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dashboard Overview",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Total registered users: $totalUsers",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
            MediaQuery.of(context).size.width < 360 ? 1.2 : 1.35,
            children: [
              buildSummaryCard(
                title: "Tracks",
                value: dashboardStats.length.toString(),
                icon: Icons.route,
                color: const Color(0xff0665BC),
              ),
              buildSummaryCard(
                title: "Users",
                value: totalUsers.toString(),
                icon: Icons.people,
                color: Colors.green,
              ),
              buildSummaryCard(
                title: "Beginner",
                value: getLevelTotal("beginner").toString(),
                icon: Icons.star_border,
                color: Colors.orange,
              ),
              buildSummaryCard(
                title: "Advanced",
                value: getLevelTotal("advanced").toString(),
                icon: Icons.workspace_premium,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Track Statistics",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...dashboardStats.map((track) {
            return buildTrackStatsCard(track);
          }).toList(),
        ],
      ),
    );
  }

  int getLevelTotal(String levelName) {
    int total = 0;

    for (final track in dashboardStats) {
      for (final level in track.levels) {
        if (level.level.toLowerCase() == levelName.toLowerCase()) {
          total += level.usersCount;
        }
      }
    }

    return total;
  }

  Widget buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTrackStatsCard(TrackStatsModel track) {
    final beginner = getTrackLevelCount(track, "beginner");
    final intermediate = getTrackLevelCount(track, "intermediate");
    final advanced = getTrackLevelCount(track, "advanced");

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xffEAF4FF),
                  child: Text(
                    track.trackName.isNotEmpty
                        ? track.trackName[0].toUpperCase()
                        : "T",
                    style: const TextStyle(
                      color: Color(0xff0665BC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    track.trackName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff0665BC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${track.totalUsers} Users",
                    style: const TextStyle(
                      color: Color(0xff0665BC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: buildLevelBox(
                    title: "Beginner",
                    count: beginner,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: buildLevelBox(
                    title: "Intermediate",
                    count: intermediate,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: buildLevelBox(
                    title: "Advanced",
                    count: advanced,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int getTrackLevelCount(TrackStatsModel track, String levelName) {
    for (final level in track.levels) {
      if (level.level.toLowerCase() == levelName.toLowerCase()) {
        return level.usersCount;
      }
    }
    return 0;
  }

  Widget buildLevelBox({
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadUsers() async {
    try {
      final data = await AdminApi.getUsers();
      setState(() {
        users = data;
        isLoadingUsers = false;
      });
    } catch (e) {
      setState(() => isLoadingUsers = false);
    }
  }

  Future<void> confirmDeleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AdminApi.deleteUser(id);
      loadUsers();
      loadDashboard();
    }
  }

  Widget usersTab() {
    if (isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        return Card(
          child: ListTile(
            title: Text(user.fullName),
            subtitle: Text("${user.email}\n${user.role}"),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () async {
                    await AdminApi.makeAdmin(user.id);
                    loadUsers();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => confirmDeleteUser(user.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loadTracks() async {
    try {
      final data = await AdminTracksApi.getTracks();
      setState(() {
        tracks = data;
        isLoadingTracks = false;
      });
    } catch (e) {
      setState(() => isLoadingTracks = false);
    }
  }

  void showTrackDialog({Map<String, dynamic>? track}) {
    final nameController = TextEditingController(text: track?["name"] ?? "");
    final descController =
    TextEditingController(text: track?["description"] ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(track == null ? "Add Track" : "Edit Track"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Track Name"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (track == null) {
                  await AdminTracksApi.createTrack(
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                  );
                } else {
                  await AdminTracksApi.updateTrack(
                    id: track["id"],
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                  );
                }

                if (!mounted) return;
                Navigator.pop(context);
                loadTracks();
                loadDashboard();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmDeleteTrack(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Track"),
        content: const Text("Are you sure you want to delete this track?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AdminTracksApi.deleteTrack(id);
      loadTracks();
      loadDashboard();
    }
  }

  Widget tracksTab() {
    if (isLoadingTracks) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];

            return Card(
              child: ListTile(
                title: Text(track["name"] ?? ""),
                subtitle: Text(track["description"] ?? ""),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showTrackDialog(track: track),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => confirmDeleteTrack(track["id"]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: const Color(0xff0665BC),
            onPressed: () => showTrackDialog(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> loadCourses() async {
    try {
      final data = await AdminCoursesApi.getCourses();
      setState(() {
        courses = data;
        isLoadingCourses = false;
      });
    } catch (e) {
      setState(() => isLoadingCourses = false);
    }
  }

  void showCourseDialog({Map<String, dynamic>? course}) {
    final title = TextEditingController(text: course?["title"] ?? "");
    final desc = TextEditingController(text: course?["description"] ?? "");
    final order = TextEditingController(text: "${course?["order"] ?? 0}");

    int? selectedTrackId = course?["trackId"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(course == null ? "Add Course" : "Edit Course"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: title,
                      decoration:
                      const InputDecoration(labelText: "Course Title"),
                    ),
                    TextField(
                      controller: desc,
                      decoration:
                      const InputDecoration(labelText: "Description"),
                    ),
                    TextField(
                      controller: order,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Order"),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedTrackId,
                      decoration: const InputDecoration(
                        labelText: "Choose Track",
                        border: OutlineInputBorder(),
                      ),
                      items: tracks.map((track) {
                        return DropdownMenuItem<int>(
                          value: track["id"],
                          child: Text(track["name"] ?? "Track"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedTrackId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final courseTitle = title.text.trim();
                    final courseDesc = desc.text.trim();
                    final courseOrder = int.tryParse(order.text.trim()) ?? 0;

                    if (courseTitle.isEmpty ||
                        courseDesc.isEmpty ||
                        selectedTrackId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    if (course == null) {
                      await AdminCoursesApi.createCourse(
                        title: courseTitle,
                        description: courseDesc,
                        order: courseOrder,
                        trackId: selectedTrackId!,
                      );
                    } else {
                      await AdminCoursesApi.updateCourse(
                        id: course["id"],
                        title: courseTitle,
                        description: courseDesc,
                        order: courseOrder,
                        trackId: selectedTrackId!,
                      );
                    }

                    if (!mounted) return;
                    Navigator.pop(context);
                    loadCourses();
                    loadDashboard();
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> confirmDeleteCourse(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Course"),
        content: const Text("Are you sure you want to delete this course?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AdminCoursesApi.deleteCourse(id);
      loadCourses();
      loadDashboard();
    }
  }

  Widget coursesTab() {
    if (isLoadingCourses) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];

            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonsAdminScreen(
                        courseId: course["id"],
                        courseTitle: course["title"],
                      ),
                    ),
                  );
                },
                title: Text(course["title"] ?? ""),
                subtitle: Text(course["description"] ?? ""),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showCourseDialog(course: course),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => confirmDeleteCourse(course["id"]),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: const Color(0xff0665BC),
            onPressed: () => showCourseDialog(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: adminDrawer(),
      backgroundColor: const Color(0xffF7F3FA),
      appBar: AppBar(
        backgroundColor: const Color(0xff0665BC),
        foregroundColor: Colors.white,
        title: const Text("Admin Panel"),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: "Dashboard"),
            Tab(text: "Users"),
            Tab(text: "Tracks"),
            Tab(text: "Courses"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          dashboardTab(),
          usersTab(),
          tracksTab(),
          coursesTab(),
        ],
      ),
    );
  }
}