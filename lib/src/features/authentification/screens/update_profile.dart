import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  bool _emailVerified = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser!;
    _emailVerified = refreshedUser.emailVerified;

    final snapshot = await FirebaseFirestore.instance.collection('Users').doc(refreshedUser.uid).get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      _fullNameController.text = data['fullName'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phoneNo'] ?? '';
    }

    setState(() {});
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser!;
      _emailVerified = refreshedUser.emailVerified;
      setState(() {});

      if (refreshedUser.email != _emailController.text.trim() && !_emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Сначала подтвердите текущий email.")),
        );
        setState(() => _loading = false);
        return;
      }

      final newEmail = _emailController.text.trim();
      final isEmailChanged = refreshedUser.email != newEmail;

      if (isEmailChanged) {
        _showReauthDialog(
          onVerified: (String password) async {
            try {
              final cred = EmailAuthProvider.credential(
                email: refreshedUser.email!,
                password: password,
              );
              await refreshedUser.reauthenticateWithCredential(cred);
              await refreshedUser.updateEmail(newEmail);
              await _applyProfileChanges(refreshedUser.uid, newEmail);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Ошибка при смене email: $e")),
              );
            } finally {
              setState(() => _loading = false);
            }
          },
        );
      } else {
        await _applyProfileChanges(refreshedUser.uid, refreshedUser.email!);
        setState(() => _loading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e")),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _applyProfileChanges(String uid, String email) async {
    await FirebaseFirestore.instance.collection('Users').doc(uid).update({
      'fullName': _fullNameController.text.trim(),
      'email': email,
      'phoneNo': _phoneController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Профиль обновлён")),
    );
    Navigator.pop(context);
  }

  void _showReauthDialog({required void Function(String password) onVerified}) {
    final _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Подтвердите личность"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Введите текущий пароль для подтверждения."),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Пароль"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onVerified(_passwordController.text.trim());
            },
            child: const Text("Подтвердить"),
          ),
        ],
      ),
    );
  }

  Future<void> _changePasswordDialog() async {
    final _newPasswordController = TextEditingController();
    final _currentPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Изменить пароль"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Текущий пароль"),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Новый пароль"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Отмена")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _updatePassword(
                _currentPasswordController.text.trim(),
                _newPasswordController.text.trim(),
              );
            },
            child: const Text("Сохранить"),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (user == null || email == null) return;

      final cred = EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пароль обновлён")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка смены пароля: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Редактировать профиль")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: "Имя"),
                validator: (value) => value!.isEmpty ? "Введите имя" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Введите email" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Телефон"),
                validator: (value) => value!.isEmpty ? "Введите номер" : null,
              ),
              const SizedBox(height: 10),

              if (!_emailVerified)
                TextButton(
                  onPressed: () async {
                    await user?.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Письмо подтверждения отправлено")),
                    );
                  },
                  child: const Text("Отправить подтверждение на email"),
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text("Сохранить изменения"),
              ),
              TextButton(
                onPressed: _changePasswordDialog,
                child: const Text("Изменить пароль"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
