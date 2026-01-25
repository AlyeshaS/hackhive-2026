import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../gemini_service.dart';

class DeepTalkService {
  final GeminiService _geminiService = GeminiService();

  /// Loads topics from Firestore, or generates via Gemini if not present.
  Future<List<Map<String, dynamic>>> getOrGenerateTopics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final topicsRef = FirebaseFirestore.instance
        .collection('deep_talk')
        .doc(user.uid)
        .collection('topics');
    final snapshot = await topicsRef.get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs
          .map((doc) => {'id': doc['id'], 'topic': doc['topic']})
          .toList();
    }
    // If not found, generate from Gemini
    final aiTopics = await _geminiService.generateDeepTalkTopics();
    final batch = FirebaseFirestore.instance.batch();
    for (final topic in aiTopics) {
      final docRef = topicsRef.doc(topic['id']);
      batch.set(docRef, topic);
    }
    await batch.commit();
    return aiTopics;
  }

  /// Always generates new topics from Gemini and replaces the user's topics in Firestore.
  Future<List<Map<String, dynamic>>> generateAndReplaceTopics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final topicsRef = FirebaseFirestore.instance
        .collection('deep_talk')
        .doc(user.uid)
        .collection('topics');
    // Delete all existing topics
    final snapshot = await topicsRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    // Generate new topics from Gemini
    final aiTopics = await _geminiService.generateDeepTalkTopics();
    final batch = FirebaseFirestore.instance.batch();
    for (final topic in aiTopics) {
      final docRef = topicsRef.doc(topic['id']);
      batch.set(docRef, topic);
    }
    await batch.commit();
    return aiTopics;
  }

  /// Loads completed topics from Firestore
  Future<List<Map<String, dynamic>>> getCompletedTopics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final completedRef = FirebaseFirestore.instance
        .collection('deep_talk')
        .doc(user.uid)
        .collection('completed');
    final snapshot = await completedRef.get();
    return snapshot.docs
        .map((doc) => {'id': doc['id'], 'topic': doc['topic']})
        .toList();
  }

  /// Marks a topic as completed in Firestore
  Future<void> markAsComplete(Map<String, dynamic> topic) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('deep_talk')
        .doc(user.uid)
        .collection('completed')
        .doc(topic['id'])
        .set(topic);
  }
}
