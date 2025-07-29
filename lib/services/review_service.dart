import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('reviews');

  /// Сохраняет отзыв в Firestore
  Future<void> saveReview(Review review) async {
    try {
      await _collection.add(review.toMap());
      print('✅ Отзыв сохранён: ${review.text}');
    } catch (e) {
      print('❌ Ошибка при сохранении отзыва: $e');
    }
  }

  /// Загружает все отзывы по полю с указанным fieldId
  Future<List<Review>> loadReviews(String fieldId) async {
    try {
      final snapshot = await _collection
          .where('fieldId', isEqualTo: fieldId)
          .orderBy('timestamp', descending: true)
          .get();

      final reviews = snapshot.docs
          .map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      print('📥 Загрузили ${reviews.length} отзывов для поля $fieldId');
      return reviews;
    } catch (e) {
      print('❌ Ошибка при загрузке отзывов: $e');
      return [];
    }
  }
}
