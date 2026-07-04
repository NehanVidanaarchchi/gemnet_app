import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/firestore_service.dart';
import '../../models/chat_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';
import '../chat/chat_screen.dart';

/// Admin can view all buyer-seller conversations (read/monitor only in
/// spirit — technically reuses ChatScreen so admin *could* reply, but the
/// UI is intended for oversight of transactions/disputes).
class AdminChatsScreen extends StatelessWidget {
  const AdminChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('All Conversations', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: StreamBuilder<List<ChatModel>>(
            stream: fs.watchAllChats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const InlineLoading();
              final chats = snapshot.data!;
              if (chats.isEmpty) {
                return const Center(child: Text('No conversations yet', style: TextStyle(color: AppColors.midGrey)));
              }
              return ListView.separated(
                itemCount: chats.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final chat = chats[i];
                  return ListTile(
                    leading: const Icon(Icons.forum_outlined, color: AppColors.midGrey),
                    title: Text('${chat.buyerName}  ↔  ${chat.sellerName}', style: const TextStyle(color: AppColors.white, fontSize: 13)),
                    subtitle: Text('${chat.gemTitle} • ${chat.lastMessage}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.midGrey)),
                    trailing: Text(timeago.format(chat.lastMessageAt, locale: 'en_short'), style: const TextStyle(color: AppColors.midGrey, fontSize: 11)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(chatId: chat.id, otherPartyName: '${chat.buyerName} / ${chat.sellerName}', gemTitle: chat.gemTitle),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
