import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String name;
  final String fieldId;
  final DateTime dateTime;

  Booking({required this.name, required this.fieldId, required this.dateTime});

  Map<String, dynamic> toJson() => {
    'name': name,
    'fieldId': fieldId,
    'dateTime': Timestamp.fromDate(dateTime),
  };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    name: json['name'],
    fieldId: json['fieldId'],
    dateTime: (json['dateTime'] as Timestamp).toDate(),
  );
}

class BookingService {
  final _collection = FirebaseFirestore.instance.collection('bookings');

  Future<void> saveBooking(Booking booking) async {
    await _collection.add(booking.toJson());
  }

  Future<List<Booking>> loadBookings() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList();
  }

  Future<List<Booking>> loadFutureBookings(String fieldId) async {
    final now = Timestamp.now();
    final snapshot = await _collection
        .where('fieldId', isEqualTo: fieldId)
        .where('dateTime', isGreaterThan: now)
        .orderBy('dateTime')
        .get();

    return snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList();
  }

  Future<List<int>> getHourlyStats(String fieldId) async {
    final snapshot = await _collection
        .where('fieldId', isEqualTo: fieldId)
        .get();

    final List<int> hourlyCounts = List.filled(24, 0);
    for (var doc in snapshot.docs) {
      final dateTime = (doc['dateTime'] as Timestamp?)?.toDate();
      if (dateTime == null) continue;

      final hour = dateTime.hour;
      if (hour >= 0 && hour < 24) {
        hourlyCounts[hour]++;
      }
    }
    return hourlyCounts;
  }
}
