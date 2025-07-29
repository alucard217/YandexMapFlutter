import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class ReviewForm extends StatefulWidget {
  final String fieldId;
  final String userId;

  const ReviewForm({required this.fieldId, required this.userId, super.key});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _controller = TextEditingController();
  double _rating = 3.0;
  final _service = ReviewService();

  void _submit() async {
    final comment = _controller.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите комментарий')),
      );
      return;
    }

    final review = Review(
      userId: widget.userId,
      fieldId: widget.fieldId,
      text: _controller.text.trim(),
      timestamp: DateTime.now(),
      rating: _rating, // ← обязательно
    );


    await _service.saveReview(review);

    _controller.clear();
    setState(() => _rating = 3.0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отзыв успешно отправлен')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Оставить отзыв:", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Ваш комментарий'),
        ),
        const SizedBox(height: 12),
        Text("Оценка: ${_rating.toStringAsFixed(1)}"),
        Slider(
          value: _rating,
          onChanged: (val) => setState(() => _rating = val),
          min: 1,
          max: 5,
          divisions: 4,
          label: _rating.toStringAsFixed(1),
        ),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Send Review', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
