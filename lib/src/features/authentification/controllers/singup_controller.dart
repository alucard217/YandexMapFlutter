import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yandexmap/map_booking_screen.dart';
import 'package:yandexmap/src/features/authentification/models/users_model.dart';
import 'package:yandexmap/src/repository/auth_repository.dart';
import 'package:yandexmap/src/repository/user_repository/user_repository.dart';

class SignUpController extends GetxController {
  final email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final phoneNo = TextEditingController();

  static SignUpController get instance => Get.find();

  void phoneAuthentification(String phoneNo) {
    AuthentificationRepository.instance.phoneAuthentification(phoneNo);
  }

  /// 🔐 Регистрация пользователя и сохранение в Firestore
  Future<void> registerUser(BuildContext context, String email, String password) async {
    try {
      print("📤 Регистрируем пользователя $email");

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        final newUser = UsersModel(
          id: user.uid,
          fullName: fullName.text.trim(),
          email: email.trim(),
          phoneNo: phoneNo.text.trim(),
          role: 'user',
        );

        try {
          await UserRepository.saveUser(newUser);
          print("✅ Firestore: пользователь сохранён");
        } catch (e) {
          print("❌ Ошибка сохранения в Firestore: $e");
        }
        print("✅ Пользователь сохранён в Firestore: ${user.uid}");

        Get.snackbar("Успех", "Вы успешно зарегистрированы");

        // Навигация на карту
        Get.offAll(() => const MapBooking());
      } else {
        print("⚠️ Пользователь равен null после регистрации");
        throw Exception("Пользователь не создан");
      }
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration failed"), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("❌ Unknown error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Что-то пошло не так. Попробуйте снова."), backgroundColor: Colors.red),
      );
    }
  }

  /// 🔓 Авторизация и переход на карту
Future<void> loginUser(BuildContext context, String email, String password) async {
  print("📤 Логин пользователя: $email");

  try {
    UserCredential credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    if (credential.user != null) {
      print("✅ Успешный логин. Переход к MapBooking");
      Get.offAll(() => const MapBooking());
    } else {
      print("⚠️ Логин неудачный, пользователь null");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Неверный логин или пароль"), backgroundColor: Colors.red),
      );
    }
  } on FirebaseAuthException catch (e) {
    print("❌ FirebaseAuthException: ${e.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? "Ошибка входа"), backgroundColor: Colors.red),
    );
  } catch (e) {
    print("❌ Unknown error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Что-то пошло не так"), backgroundColor: Colors.red),
    );
  }
}

}
