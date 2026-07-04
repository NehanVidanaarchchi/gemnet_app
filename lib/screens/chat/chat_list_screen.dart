import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/app_state.dart';
import '../../services/firestore_service.dart';
import '../../models/chat_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppState>().currentUserProfile;
    if (me == null) return const SizedBox.shrink();
    final firestore = FirestoreService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('Chats', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: StreamBuilder<List<ChatModel>>(
            stream: firestore.watchUserChats(me.uid),
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
                  final isBuyer = chat.buyerId == me.uid;
                  final otherName = isBuyer ? chat.sellerName : chat.buyerName;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.charcoal,
                      backgroundImage: chat.gemImage != null ? NetworkImage(chat.gemImage!) : null,
                      child: chat.gemImage == null ? const Icon(Icons.diamond_outlined, color: AppColors.midGrey) : null,
                    ),
                    title: Text(otherName, style: const TextStyle(color: AppColors.white)),
                    subtitle: Text('${chat.gemTitle} • ${chat.lastMessage}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.midGrey)),
                    trailing: Text(timeago.format(chat.lastMessageAt, locale: 'en_short'),
                        style: const TextStyle(color: AppColors.midGrey, fontSize: 11)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(chatId: chat.id, otherPartyName: otherName, gemTitle: chat.gemTitle),
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
