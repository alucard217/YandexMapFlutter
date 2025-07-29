import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yandexmap/src/features/authentification/models/users_model.dart';

class UserRepository {
  static final _db = FirebaseFirestore.instance;

  /// 🔹 Сохранить пользователя в Firestore
static Future<void> saveUser(UsersModel user) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) throw Exception("User not logged in");

  print("💾 [UserRepository] UID: $uid");
  print("📦 Данные для сохранения: ${user.toJson()}");

  await _db.collection("Users").doc(uid).set(user.toJson());

  print("✅ Пользователь сохранён в Firestore");
}


  /// 🔹 Получить данные пользователя по ID
  static Future<UsersModel> getUserById(String uid) async {
    final snapshot = await _db.collection("Users").doc(uid).get();
    if (!snapshot.exists) throw Exception("User not found");

    return UsersModel.fromSnapshot(snapshot.data()!, snapshot.id);
  }

  /// 🔹 Получить роль пользователя
  static Future<String> getUserRole(String uid) async {
    final snapshot = await _db.collection("Users").doc(uid).get();
    if (!snapshot.exists) return "user";

    final data = snapshot.data()!;
    return (data['role'] ?? 'user').toString().trim(); // 👈 trim убирает пробелы
  }


  /// 🔹 Получить список всех пользователей (например, для админа)
  static Future<List<UsersModel>> getAllUsers() async {
    final query = await _db.collection("Users").get();
    return query.docs.map((doc) => UsersModel.fromSnapshot(doc.data(), doc.id)).toList();
  }

  /// 🔹 Обновить данные пользователя
  static Future<void> updateUser(UsersModel user) async {
    if (user.id == null) throw Exception("User ID is required");
    await _db.collection("Users").doc(user.id).update(user.toJson());
  }

  /// 🔹 Удалить пользователя (используется только админом)
  static Future<void> deleteUser(String uid) async {
    await _db.collection("Users").doc(uid).delete();
  }
}
