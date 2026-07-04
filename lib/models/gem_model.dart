import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle of a gem listing.
/// pending  -> waiting for admin approval
/// approved -> live, visible to buyers
/// rejected -> admin rejected
/// soldout  -> seller marked as sold
enum GemStatus { pending, approved, rejected, soldout }

GemStatus gemStatusFromString(String s) {
  switch (s) {
    case 'approved':
      return GemStatus.approved;
    case 'rejected':
      return GemStatus.rejected;
    case 'soldout':
      return GemStatus.soldout;
    default:
      return GemStatus.pending;
  }
}

String gemStatusToString(GemStatus s) => s.name;

class GemModel {
  final String id; // Firestore doc id
  final String gemId; // short public certificate code e.g. GEM-A1B2C3
  final String sellerId;
  final String sellerName;

  final String title;
  final String type; // e.g. Blue Sapphire
  final String color;
  final double weightCarat;
  final String cut;
  final String clarityNotes;
  final String transparency;
  final String originGuess;
  final String description;

  final double price;
  final String currency; // LKR / USD

  final List<String> imageUrls;
  final GemStatus status;
  final String? rejectionReason;

  final Map<String, dynamic>? aiRaw; // raw Groq response for audit/confidence

  final DateTime createdAt;

  GemModel({
    required this.id,
    required this.gemId,
    required this.sellerId,
    required this.sellerName,
    required this.title,
    required this.type,
    required this.color,
    required this.weightCarat,
    required this.cut,
    required this.clarityNotes,
    required this.transparency,
    required this.originGuess,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrls,
    required this.status,
    this.rejectionReason,
    this.aiRaw,
    required this.createdAt,
  });

  factory GemModel.fromMap(String id, Map<String, dynamic> map) {
    return GemModel(
      id: id,
      gemId: map['gemId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      color: map['color'] ?? '',
      weightCarat: (map['weightCarat'] ?? 0).toDouble(),
      cut: map['cut'] ?? '',
      clarityNotes: map['clarityNotes'] ?? '',
      transparency: map['transparency'] ?? '',
      originGuess: map['originGuess'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'LKR',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      status: gemStatusFromString(map['status'] ?? 'pending'),
      rejectionReason: map['rejectionReason'],
      aiRaw: map['aiRaw'] != null ? Map<String, dynamic>.from(map['aiRaw']) : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gemId': gemId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'title': title,
      'type': type,
      'color': color,
      'weightCarat': weightCarat,
      'cut': cut,
      'clarityNotes': clarityNotes,
      'transparency': transparency,
      'originGuess': originGuess,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrls': imageUrls,
      'status': gemStatusToString(status),
      'rejectionReason': rejectionReason,
      'aiRaw': aiRaw,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
