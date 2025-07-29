import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String userId;
  final String fieldId;
  final String text;
  final DateTime timestamp;
  final double rating;

  Review({
    required this.userId,
    required this.fieldId,
    required this.text,
    required this.timestamp,
    this.rating = 3.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fieldId': fieldId,
      'text': text,
      'timestamp': timestamp,
      'rating': rating,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'] ?? 'guest',
      fieldId: map['fieldId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      rating: (map['rating'] ?? 3).toDouble(),
    );
  }
}


