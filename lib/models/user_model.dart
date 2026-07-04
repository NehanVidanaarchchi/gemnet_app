import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { buyer, seller, admin }

UserRole roleFromString(String s) {
  switch (s) {
    case 'seller':
      return UserRole.seller;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.buyer;
  }
}

String roleToString(UserRole r) => r.name;

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final UserRole role;
  final bool isVerifiedSeller; // sellers approved by admin
  final bool isBanned;
  final String? phone;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.role,
    this.isVerifiedSeller = false,
    this.isBanned = false,
    this.phone,
    required this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      role: roleFromString(map['role'] ?? 'buyer'),
      isVerifiedSeller: map['isVerifiedSeller'] ?? false,
      isBanned: map['isBanned'] ?? false,
      phone: map['phone'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': roleToString(role),
      'isVerifiedSeller': isVerifiedSeller,
      'isBanned': isBanned,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    UserRole? role,
    bool? isVerifiedSeller,
    bool? isBanned,
    String? phone,
    String? name,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isVerifiedSeller: isVerifiedSeller ?? this.isVerifiedSeller,
      isBanned: isBanned ?? this.isBanned,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
}
