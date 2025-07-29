import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:yandexmap/map_booking_screen.dart';
import 'package:yandexmap/src/constants/sizes.dart';
import 'package:yandexmap/src/features/authentification/chat/chat_users.dart';
import 'package:yandexmap/src/features/authentification/screens/admin_dashboard.dart';
import 'package:yandexmap/src/features/authentification/screens/update_profile.dart';
import 'package:yandexmap/src/features/authentification/screens/welcome_screen.dart';
import 'package:yandexmap/src/features/authentification/settings/settings.dart';
import 'package:yandexmap/src/repository/user_repository/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = 'Загрузка...';
  String email = '';
  String role = '';
  String? photoUrl;
  String? userRole;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> getCurrentUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final role = await UserRepository.getUserRole(uid);
      setState(() {
        userRole = role;
      });
    }
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        fullName = data['fullName'] ?? 'Имя не указано';
        email = data['email'] ?? '';
        role = data['role'] ?? '';
        photoUrl = data['photoUrl'];
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance.ref().child('avatars/${user.uid}.jpg');

      try {
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
          'photoUrl': downloadUrl,
        });

        setState(() {
          photoUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото успешно обновлено')),
        );
      } catch (e) {
        print('Ошибка при загрузке: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось загрузить фото')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LineAwesomeIcons.angle_left_solid),
        ),
        title: const Text("Профиль"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(isDarkMode ? LineAwesomeIcons.sun : LineAwesomeIcons.moon),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(tDefaultSize),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl!) : const AssetImage("assets/images/profile_img.jpg") as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: pickAndUploadImage,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LineAwesomeIcons.pencil_alt_solid, size: 20, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(fullName, style: Theme.of(context).textTheme.titleLarge),
            Text(email, style: Theme.of(context).textTheme.bodyMedium),
            if (role.isNotEmpty)
              Text("Роль: $role", style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpdateProfileScreen()),
                ).then((_) => loadUserData());
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            ProfileMenuWidget(
              title: "Settings",
              icon: LineAwesomeIcons.cog_solid,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen()),
                );
              },
            ),
            ProfileMenuWidget(title: "Payment", icon: LineAwesomeIcons.wallet_solid, onPress: () {}),
            ProfileMenuWidget(title: "Management", icon: LineAwesomeIcons.user_check_solid, onPress: () {}),
            const Divider(),
            const SizedBox(height: 10),
            ProfileMenuWidget(
              title: "Logout",
              icon: LineAwesomeIcons.sign_out_alt_solid,
              textColor: Colors.red,
              endIcon: false,
              onPress: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          logout();
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MapBooking()));
          } else if (index == 2 && userRole == 'admin') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
          } else if (index == 2 && userRole == 'user') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UsersChat(receiverUserEmail: '',)));
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          if (userRole == 'admin')
            const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
          if (userRole == 'user')
            const BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        ],
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = textColor ?? (isDarkMode ? Colors.white : Colors.black);

    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor)),
      trailing: endIcon
          ? const Icon(LineAwesomeIcons.angle_right_solid, size: 18, color: Colors.grey)
          : null,
    );
  }
}
