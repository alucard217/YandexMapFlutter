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
        child: Text("No reviews yet.", style: TextStyle(fontSize: 14)),
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
                Text(review.userId, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(review.text),

                // 🔽 ВСТАВЬ СЮДА ЭТО:
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text('${review.rating.toStringAsFixed(1)} / 5'),
                  ],
                ),

                // 🔽 Можешь также добавить дату:
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${review.timestamp.day}.${review.timestamp.month}.${review.timestamp.year}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
