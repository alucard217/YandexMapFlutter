import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewsList extends StatelessWidget {
  final List<Review> reviews;

  const ReviewsList({required this.reviews, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No reviews yet", style: TextStyle(fontSize: 14)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.userId,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(review.text),
                const SizedBox(height: 4),
                Text(
                  '${review.timestamp.day.toString().padLeft(2, '0')}.'
                  '${review.timestamp.month.toString().padLeft(2, '0')}.'
                  '${review.timestamp.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
