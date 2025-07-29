import 'package:flutter/material.dart';

class AddReviewField extends StatefulWidget {
  final void Function(String) onAddReview;
  final String fieldId;

  const AddReviewField({
    required this.fieldId,
    required this.onAddReview,
    Key? key,
  }) : super(key: key);

  @override
  State<AddReviewField> createState() => _AddReviewFieldState();
}

class _AddReviewFieldState extends State<AddReviewField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Оставьте отзыв...',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              widget.onAddReview(text);
              _controller.clear();
            }
          },
        ),
      ],
    );
  }
}

