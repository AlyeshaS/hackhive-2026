import 'package:cloud_firestore/cloud_firestore.dart';

class ScrapbookEntry {
  final String id;
  final String authorId;
  final String recipientId;
  final DateTime entryDate;
  final String imageUrl;
  final String imagePath;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScrapbookEntry({
    required this.id,
    required this.authorId,
    required this.recipientId,
    required this.entryDate,
    required this.imageUrl,
    required this.imagePath,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  String get dateKey => dateKeyFor(entryDate);

  bool get hasImage => imageUrl.isNotEmpty;

  static String dateKeyFor(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  factory ScrapbookEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    final entryTs = data['entryDate'] as Timestamp?;
    final createdTs = data['createdAt'] as Timestamp?;
    final updatedTs = data['updatedAt'] as Timestamp?;

    return ScrapbookEntry(
      id: doc.id,
      authorId: (data['authorId'] as String?) ?? '',
      recipientId: (data['recipientId'] as String?) ?? '',
      entryDate: entryTs?.toDate() ?? DateTime.now(),
      imageUrl: (data['imageUrl'] as String?) ?? '',
      imagePath: (data['imagePath'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      createdAt: createdTs?.toDate() ?? DateTime.now(),
      updatedAt: updatedTs?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'recipientId': recipientId,
      'entryDate': Timestamp.fromDate(
        DateTime(entryDate.year, entryDate.month, entryDate.day),
      ),
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
