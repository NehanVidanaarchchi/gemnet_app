import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id; // deterministic: sorted(buyerId_sellerId)_gemId
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String gemId; // firestore doc id of gem (nullable-safe as empty string)
  final String gemTitle;
  final String? gemImage;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String lastSenderId;

  ChatModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.gemId,
    required this.gemTitle,
    this.gemImage,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastSenderId,
  });

  factory ChatModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatModel(
      id: id,
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      gemId: map['gemId'] ?? '',
      gemTitle: map['gemTitle'] ?? '',
      gemImage: map['gemImage'],
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSenderId: map['lastSenderId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'gemId': gemId,
      'gemTitle': gemTitle,
      'gemImage': gemImage,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastSenderId': lastSenderId,
      'participants': [buyerId, sellerId],
    };
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }
}
