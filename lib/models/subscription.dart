import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String? id;
  final String email;
  final Timestamp subscribedAt;

  Subscription({
    this.id,
    required this.email,
    required this.subscribedAt,
  });

  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: doc.id,
      email: data['email'] ?? '',
      subscribedAt: data['subscribedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'subscribedAt': subscribedAt,
    };
  }
}