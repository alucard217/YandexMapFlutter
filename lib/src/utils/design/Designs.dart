import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MyListTile({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(Icons.person, color: Theme.of(context).colorScheme.inversePrimary,),
        title: Text(title, style: TextStyle(color: Colors.black)),
        onTap: onTap,
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Alignment alignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Map<String, dynamic> data;
  final Color color;

  const MessageBubble({
    required this.alignment,
    required this.crossAxisAlignment,
    required this.data,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            data["senderEmail"],
            style: const TextStyle(color: Colors.black54),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                data["message"],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    secondary: Colors.grey.shade100,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
  ),
);

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    secondary: Colors.grey.shade700,
    tertiary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade300,
  ),
);


