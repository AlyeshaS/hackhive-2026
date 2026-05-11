import 'package:cloud_firestore/cloud_firestore.dart';

class LoveLetter {
  final String id;
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime createdAt;

  LoveLetter({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.createdAt,
  });

  factory LoveLetter.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['createdAt'] as Timestamp?;
    return LoveLetter(
      id: doc.id,
      senderId: (data['senderId'] as String?) ?? '',
      recipientId: (data['recipientId'] as String?) ?? '',
      text: (data['text'] as String?) ?? '',
      createdAt: ts?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'recipientId': recipientId,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
