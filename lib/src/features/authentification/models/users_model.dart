class UsersModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNo;
  final String role; // 'user' | 'admin' | 'manager'

  const UsersModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNo,
    this.role = 'user',
  });

  /// 🔁 Преобразовать в JSON для Firestore
Map<String, dynamic> toJson() {
  return {
    'fullName': fullName,
    'email': email,
    'phoneNo': phoneNo,
    'role': role,
  };
}


  /// 🔁 Создать объект из Firestore документа
  factory UsersModel.fromSnapshot(Map<String, dynamic> json, String id) {
    return UsersModel(
      id: id,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}
