import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final TextEditingController _userSearchController = TextEditingController();
  String _userSearchText = '';


  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });

    _userSearchController.addListener(() {
      setState(() {
        _userSearchText = _userSearchController.text.toLowerCase();
      });
    });


  }

  Future<void> deleteField(String fieldId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text('Вы точно хотите удалить это поле?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('fields').doc(fieldId).delete();
    }
  }


  Future<void> deleteUser(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text('Подтверждение'),
            content: const Text(
                'Вы точно хотите удалить данного пользователя?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Отмена')),
              TextButton(onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Удалить')),
            ],
          ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('Users').doc(userId).delete();
    }
  }

  Future<void> addNewField(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final typeController = TextEditingController();
    final imageController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();
    final polygonController = TextEditingController(); // формат: 51.1,71.4;51.2,71.5

    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text('Добавить новое поле'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController,
                      decoration: const InputDecoration(labelText: 'Название')),
                  TextField(controller: descController,
                      decoration: const InputDecoration(labelText: 'Описание')),
                  TextField(controller: typeController,
                      decoration: const InputDecoration(labelText: 'Тип поля')),
                  TextField(controller: imageController,
                      decoration: const InputDecoration(
                          labelText: 'Путь до изображения')),
                  TextField(controller: latController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Широта (latitude)')),
                  TextField(controller: lngController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Долгота (longitude)')),
                  TextField(
                    controller: polygonController,
                    decoration: const InputDecoration(
                      labelText: 'Полигон (lat,lng;lat,lng)',
                      hintText: 'Пример: 51.1,71.4;51.2,71.5',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final desc = descController.text.trim();
                  final type = typeController.text.trim();
                  final image = imageController.text.trim();
                  final lat = double.tryParse(latController.text.trim()) ?? 0;
                  final lng = double.tryParse(lngController.text.trim()) ?? 0;

                  final polygonText = polygonController.text.trim();
                  final polygon = polygonText.split(';').map((coord) {
                    final parts = coord.split(',');
                    return {
                      'lat': double.tryParse(parts[0]) ?? 0,
                      'lng': double.tryParse(parts[1]) ?? 0,
                    };
                  }).toList();

                  if (name.isNotEmpty && desc.isNotEmpty && image.isNotEmpty &&
                      type.isNotEmpty && lat != 0 && lng != 0) {
                    await FirebaseFirestore.instance.collection('fields').add({
                      'name': name,
                      'description': desc,
                      'type': type,
                      'image': image,
                      'latitude': lat,
                      'longitude': lng,
                      'polygon': polygon,
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Добавить'),
              ),
            ],
          ),
    );
  }


  void _editField(BuildContext context, String docId,
      Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final descController = TextEditingController(text: data['description']);
    final typeController = TextEditingController(text: data['type']);
    final imageController = TextEditingController(text: data['image']);
    final latController = TextEditingController(
        text: data['latitude']?.toString());
    final lngController = TextEditingController(
        text: data['longitude']?.toString());
    final polygonController = TextEditingController(
      text: (data['polygon'] as List<dynamic>? ?? [])
          .map((e) => "${e['lat']},${e['lng']}")
          .join(';'),
    );

    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text('Редактировать поле'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController,
                      decoration: const InputDecoration(labelText: 'Название')),
                  TextField(controller: descController,
                      decoration: const InputDecoration(labelText: 'Описание')),
                  TextField(controller: typeController,
                      decoration: const InputDecoration(labelText: 'Тип поля')),
                  TextField(controller: imageController,
                      decoration: const InputDecoration(
                          labelText: 'Путь до изображения')),
                  TextField(controller: latController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Широта')),
                  TextField(controller: lngController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Долгота')),
                  TextField(controller: polygonController,
                      decoration: const InputDecoration(
                          labelText: 'Полигон lat,lng;lat,lng')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx),
                  child: const Text('Отмена')),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final desc = descController.text.trim();
                  final type = typeController.text.trim();
                  final image = imageController.text.trim();
                  final lat = double.tryParse(latController.text.trim()) ?? 0;
                  final lng = double.tryParse(lngController.text.trim()) ?? 0;

                  final polygonText = polygonController.text.trim();
                  final polygon = polygonText.split(';').map((coord) {
                    final parts = coord.split(',');
                    return {
                      'lat': double.tryParse(parts[0]) ?? 0,
                      'lng': double.tryParse(parts[1]) ?? 0,
                    };
                  }).toList();

                  await FirebaseFirestore.instance.collection('fields').doc(
                      docId).update({
                    'name': name,
                    'description': desc,
                    'type': type,
                    'image': image,
                    'latitude': lat,
                    'longitude': lng,
                    'polygon': polygon,
                  });

                  Navigator.pop(ctx);
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ-панель'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => addNewField(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 Поиск по полям
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск по названию',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),

            /// 📍 Поля
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('fields').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final filteredDocs = docs.where((doc) {
                    final name = (doc['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchText);
                  }).toList();

                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['name'] ?? '';
                        final description = data['description'] ?? '';
                        final type = data['type'] ?? '';
                        final image = data['image'] ?? '';
                        final lat = data['latitude'];
                        final lng = data['longitude'];
                        final polygon = data['polygon'] as List<dynamic>? ?? [];

                        Widget imageWidget;
                        if (image.startsWith('http')) {
                          imageWidget = Image.network(image, height: 100, fit: BoxFit.cover);
                        } else {
                          imageWidget = Image.asset(image, height: 100, fit: BoxFit.cover);
                        }

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(description),
                                const SizedBox(height: 4),
                                Text("Тип: $type"),
                                Text("Координаты: $lat, $lng"),
                                const SizedBox(height: 4),
                                Text("Полигон (${polygon.length} точек):"),
                                ...polygon.map((p) => Text(" - ${p['lat']}, ${p['lng']}")),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: imageWidget,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _editField(context, doc.id, data)),
                                    IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteField(doc.id)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 40),
            const Text('Пользователи', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            /// 🔍 Поиск по пользователям
            TextField(
              controller: _userSearchController,
              decoration: InputDecoration(
                labelText: 'Поиск пользователя',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            /// 👥 Список пользователей
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final users = snapshot.data!.docs;

                final filteredUsers = users.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['fullName'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(_userSearchText) || email.contains(_userSearchText);
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index].data() as Map<String, dynamic>;
                    final name = user['fullName'] ?? 'Без имени';
                    final email = user['email'] ?? '';
                    final role = user['role'] ?? 'user';

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text('$email — $role'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteUser(context, filteredUsers[index].id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
