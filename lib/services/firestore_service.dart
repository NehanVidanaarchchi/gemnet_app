import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gem_model.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Gems ----------------

  String _generateGemId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no ambiguous chars
    final rnd = Random.secure();
    final code = List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'GEM-$code';
  }

  Future<String> addGem(GemModel gem) async {
    final gemId = _generateGemId();
    final docRef = _db.collection('gems').doc();
    final data = gem.toMap();
    data['gemId'] = gemId;
    await docRef.set(data);
    return docRef.id;
  }

  Future<void> updateGem(String docId, Map<String, dynamic> data) async {
    await _db.collection('gems').doc(docId).update(data);
  }

  Future<void> markSoldOut(String docId) async {
    await _db.collection('gems').doc(docId).update({'status': 'soldout'});
  }

  Future<void> setGemStatus(String docId, GemStatus status, {String? reason}) async {
    await _db.collection('gems').doc(docId).update({
      'status': gemStatusToString(status),
      'rejectionReason': reason,
    });
  }

  Stream<List<GemModel>> watchApprovedGems() {
    return _db
        .collection('gems')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => GemModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<GemModel>> watchSellerGems(String sellerId) {
    return _db
        .collection('gems')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => GemModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<GemModel>> watchPendingGems() {
    return _db
        .collection('gems')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => GemModel.fromMap(d.id, d.data())).toList());
  }

  Future<GemModel?> fetchGemByPublicId(String gemId) async {
    final query = await _db.collection('gems').where('gemId', isEqualTo: gemId.trim().toUpperCase()).limit(1).get();
    if (query.docs.isEmpty) return null;
    return GemModel.fromMap(query.docs.first.id, query.docs.first.data());
  }

  Future<GemModel?> fetchGemByDocId(String docId) async {
    final doc = await _db.collection('gems').doc(docId).get();
    if (!doc.exists) return null;
    return GemModel.fromMap(doc.id, doc.data()!);
  }

  // ---------------- Users (admin) ----------------

  Stream<List<UserModel>> watchAllUsers() {
    return _db.collection('users').orderBy('createdAt', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => UserModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> setUserBanned(String uid, bool banned) async {
    await _db.collection('users').doc(uid).update({'isBanned': banned});
  }

  Future<void> setSellerVerified(String uid, bool verified) async {
    await _db.collection('users').doc(uid).update({'isVerifiedSeller': verified});
  }

  // ---------------- Chats ----------------

  String buildChatId(String buyerId, String sellerId, String gemDocId) {
    return '${buyerId}_${sellerId}_$gemDocId';
  }

  Future<String> getOrCreateChat({
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
    required String gemDocId,
    required String gemTitle,
    String? gemImage,
  }) async {
    final chatId = buildChatId(buyerId, sellerId, gemDocId);
    final docRef = _db.collection('chats').doc(chatId);
    final doc = await docRef.get();
    if (!doc.exists) {
      final chat = ChatModel(
        id: chatId,
        buyerId: buyerId,
        buyerName: buyerName,
        sellerId: sellerId,
        sellerName: sellerName,
        gemId: gemDocId,
        gemTitle: gemTitle,
        gemImage: gemImage,
        lastMessage: 'Chat started',
        lastMessageAt: DateTime.now(),
        lastSenderId: buyerId,
      );
      await docRef.set(chat.toMap());
    }
    return chatId;
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    final chatRef = _db.collection('chats').doc(chatId);
    await chatRef.collection('messages').add(message.toMap());
    await chatRef.update({
      'lastMessage': message.text,
      'lastMessageAt': Timestamp.fromDate(message.sentAt),
      'lastSenderId': message.senderId,
    });
  }

  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MessageModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<ChatModel>> watchUserChats(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatModel.fromMap(d.id, d.data())).toList());
  }

  // ---------------- Admin: all chats (view-only) ----------------

  Stream<List<ChatModel>> watchAllChats() {
    return _db
        .collection('chats')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatModel.fromMap(d.id, d.data())).toList());
  }
}
