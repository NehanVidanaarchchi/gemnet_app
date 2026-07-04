import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/firestore_service.dart';
import '../../models/chat_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherPartyName;
  final String gemTitle;

  const ChatScreen({super.key, required this.chatId, required this.otherPartyName, required this.gemTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _firestore = FirestoreService();
  final _scrollController = ScrollController();
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final me = context.read<AppState>().currentUserProfile;
    if (me == null) return;
    setState(() => _sending = true);
    _controller.clear();
    try {
      await _firestore.sendMessage(
        widget.chatId,
        MessageModel(id: '', senderId: me.uid, senderName: me.name, text: text, sentAt: DateTime.now()),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppState>().currentUserProfile;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherPartyName, style: const TextStyle(fontSize: 16)),
            Text(widget.gemTitle, style: const TextStyle(fontSize: 11, color: AppColors.midGrey)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _firestore.watchMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const InlineLoading();
                final messages = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                if (messages.isEmpty) {
                  return const Center(child: Text('Say hello 👋', style: TextStyle(color: AppColors.midGrey)));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(14),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == me?.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.white : AppColors.charcoal,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(msg.text, style: TextStyle(color: isMe ? AppColors.black : AppColors.white)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(hintText: 'Type a message...'),
                      onSubmitted: (_) => _send(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send, size: 18),
                    style: IconButton.styleFrom(backgroundColor: AppColors.white, foregroundColor: AppColors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
