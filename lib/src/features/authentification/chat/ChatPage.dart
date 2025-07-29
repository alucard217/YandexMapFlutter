import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/design/Designs.dart';
import 'Chat_Service.dart';


class ChatPage extends StatefulWidget {
  final String receiverUserEmail;

  const ChatPage({super.key, required this.receiverUserEmail});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String receiverNickname = "";
  late String receiverProfilePictureURL = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReceiverData();
  }

  Future<void> loadReceiverData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where("email", isEqualTo: widget.receiverUserEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          receiverNickname = data["fullName"] ?? "Unknown";
          receiverProfilePictureURL = data["photoUrl"] ?? "";
          isLoading = false;
        });
      } else {
        setState(() {
          receiverNickname = "Unknown";
          receiverProfilePictureURL = "";
          isLoading = false;
        });
      }
    } catch (e) {
      print("Ошибка при загрузке данных получателя: $e");
      setState(() {
        receiverNickname = "Unknown";
        receiverProfilePictureURL = "";
        isLoading = false;
      });
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserEmail,
        _messageController.text,
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.blue,)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: receiverProfilePictureURL.isNotEmpty
                  ? NetworkImage(receiverProfilePictureURL)
                  : null,
              child: receiverProfilePictureURL.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              receiverNickname,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        _auth.currentUser?.email ?? "",
        widget.receiverUserEmail,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        return ListView(
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String currentEmail = _auth.currentUser?.email ?? "";

    return MessageBubble(
      data: data,
      alignment: (data['senderEmail'] == currentEmail)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      crossAxisAlignment: (data['senderEmail'] == currentEmail)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      color: (data['senderEmail'] == currentEmail)
          ? Colors.green
          : Colors.blue,
    );
  }

Widget _buildMessageInput() {
  final theme = Theme.of(context);
  final inputColor = theme.colorScheme.secondary;
  final iconColor = theme.brightness == Brightness.dark
      ? Colors.white
      : Colors.black;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    child: Container(
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Enter message",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.inversePrimary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_upward, color: iconColor),
              onPressed: sendMessage,
              tooltip: "Send",
            ),
          ),
        ],
      ),
    ),
  );
}
}


