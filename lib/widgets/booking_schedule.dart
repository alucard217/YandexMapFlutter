import 'package:flutter/material.dart';
import '../services/booking_service.dart';

class BookingSchedule extends StatelessWidget {
  final String fieldId;

  const BookingSchedule({required this.fieldId, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Booking>>(
      future: BookingService().loadFutureBookings(fieldId), // ✅ Используем правильный метод
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error loading bookings: Please try again later.'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Активных записей нет.'),
          );
        }

        final bookings = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(booking.name),
              subtitle: Text(
                '${booking.dateTime.day.toString().padLeft(2, '0')}.'
                '${booking.dateTime.month.toString().padLeft(2, '0')}.'
                '${booking.dateTime.year} — '
                '${booking.dateTime.hour}:${booking.dateTime.minute.toString().padLeft(2, '0')}',
              ),
            );
          },
        );
      },
    );
  }
}
