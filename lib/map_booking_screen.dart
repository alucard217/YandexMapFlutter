import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandexmap/busy_chart.dart';
import 'package:yandexmap/models/field_model.dart';
import 'package:yandexmap/models/review.dart';
import 'package:yandexmap/reviews_list.dart';
import 'package:yandexmap/services/booking_service.dart';
import 'package:yandexmap/services/review_service.dart';
import 'package:yandexmap/src/features/authentification/chat/ChatPage.dart';
import 'package:yandexmap/src/features/authentification/chat/chat_users.dart';
import 'package:yandexmap/src/features/authentification/screens/admin_dashboard.dart';
import 'package:yandexmap/src/features/authentification/screens/profile.dart';
import 'package:yandexmap/src/repository/user_repository/user_repository.dart';
import 'package:yandexmap/widgets/booking_form.dart';
import 'package:yandexmap/widgets/booking_schedule.dart';
import 'package:yandexmap/widgets/review_form.dart';

class MapBooking extends StatefulWidget {
  const MapBooking({super.key});

  @override
  State<MapBooking> createState() => _MapBookingState();
}

class _MapBookingState extends State<MapBooking> {
  late YandexMapController controller;
  List<MapObject> mapObjects = [];
  List<Field> allFields = [];
  String selectedType = 'All';
  String? userRole;
  bool _isCardOpen = false;


  String? userFullName;

  Future<void> getCurrentUserFullName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snapshot = await FirebaseFirestore.instance.collection("Users").doc(uid).get();
      setState(() {
        userFullName = snapshot.data()?['fullName'] ?? 'guest';
      });
    }
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



  @override
  void initState() {
    super.initState();
    loadFieldsFromFirestore();
    getCurrentUserRole();
    getCurrentUserFullName();
    WidgetsBinding.instance.addPostFrameCallback((_) => _moveToInitialLocation());
  }

  Future<void> loadFieldsFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('fields').get();
      allFields = snapshot.docs.map((doc) => Field.fromMap(doc.id, doc.data())).toList();
      _filterFieldsByType();
    } catch (e) {
      print('Error: $e');
    }
  }

  void _filterFieldsByType() {
    mapObjects.clear();
    for (var field in allFields) {
      if (selectedType != 'All' && field.type != selectedType) continue;

      mapObjects.addAll([
        PolygonMapObject(
          mapId: MapObjectId('polygon_${field.name}'),
          polygon: Polygon(
            outerRing: LinearRing(points: field.polygon),
            innerRings: const [],
          ),
          strokeColor: Colors.blue.withOpacity(0.5),
          fillColor: Colors.blue.withOpacity(0.2),
          strokeWidth: 2,
        ),
        PlacemarkMapObject(
          mapId: MapObjectId('marker_${field.name}'),
          point: Point(latitude: field.latitude, longitude: field.longitude),
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(getIconForType(field.type)),
              scale: 0.3,
              anchor: const Offset(0.5, 1.0),
            ),
          ),
          onTap: (self, point) {
            if (_isCardOpen) return;
            _isCardOpen = true;
            _showFieldInfo(field);
          },
        ),
      ]);
    }
    setState(() {});
  }

  String getIconForType(String type) {
    switch (type) {
      case 'Футбол': return 'assets/images/map_marks/icon_football.png';
      case 'Баскетбол': return 'assets/images/map_marks/icon_basketball.png';
      case 'Волейбол': return 'assets/images/map_marks/icon_volleyball.png';
      case 'Теннис': return 'assets/images/map_marks/icon_tennis.png';
      default: return 'assets/images/map_marks/default_marker.png';
    }
  }

  Future<void> _moveToInitialLocation() async {
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: Point(latitude: 51.1027, longitude: 71.4140),
          zoom: 800,
        ),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
    );
  }

  Future<void> _moveToUserLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: position.latitude, longitude: position.longitude),
          zoom: 15,
        ),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
    );
  }

  void _showFieldInfo(Field field) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(field.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                field.image.startsWith('http')
                    ? Image.network(
                  field.image,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text("Error loading URL"),
                )
                    : Image.asset(
                  field.image,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text("Error loading asset"),
                ),
                const SizedBox(height: 8),
                Text(field.description),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Graph of bookings:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<int>>(
                        future: BookingService().getHourlyStats(field.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          return BusyChart(hourlyData: snapshot.data!);
                        },
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 16),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reviews:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded( // 💡 чтобы ListView не вылезал
                        child: FutureBuilder<List<Review>>(
                          future: ReviewService().loadReviews(field.id),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                            final reviews = snapshot.data!;
                            if (reviews.isEmpty) {
                              return const Center(child: Text("No reviews yet"));
                            }

                            return Scrollbar(
                              child: ListView.builder(
                                itemCount: reviews.length,
                                itemBuilder: (context, index) {
                                  final review = reviews[index];
                                  final dateStr = '${review.timestamp.day}.${review.timestamp.month}.${review.timestamp.year}';
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(review.userId, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(review.text),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 16, color: Colors.amber),
                                              Text('${review.rating.toStringAsFixed(1)} / 5'),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              dateStr,
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
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
                    ],
                  ),
                ),



                const SizedBox(height: 8),

                // ✍️ Форма отзыва с именем пользователя
                ReviewForm(fieldId: field.id, userId: userFullName ?? 'guest'),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => BookingForm(
                              fieldId: field.id,
                              onBookingComplete: () => setState(() {}),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const FittedBox(
                          child: Text("Book"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Schedule"),
                              content: SizedBox(
                                height: 300,
                                width: double.maxFinite,
                                child: BookingSchedule(fieldId: field.id),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Schedule"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      _isCardOpen = false;
    });
  }



  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        YandexMap(
          onMapCreated: (ctrl) => controller = ctrl,
          mapObjects: mapObjects,
        ),
        SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedType,
                    underline: const SizedBox(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                        _filterFieldsByType();
                      });
                    },
                    items: ['All', 'Football', 'Basketball', 'Volleyball', 'Tennis']
                        .map((type) => DropdownMenuItem(value: type, child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(type),
                        )))
                        .toList(),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _moveToUserLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          } else if (index == 2  && userRole == 'admin') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
          }
          if (index == 2  && userRole == 'user') {
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




