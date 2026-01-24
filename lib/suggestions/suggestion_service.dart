import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuggestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveSuggestion(String suggestionId, Map<String, dynamic> data) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not signed in');
    await _firestore.collection('suggestions').doc(suggestionId).set(data);
  }

  Stream<QuerySnapshot> getSuggestionsStream() {
    return _firestore.collection('suggestions').snapshots();
  }

  Future<void> swipeSuggestion(String suggestionId, bool liked) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not signed in');
    await _firestore.collection('suggestions').doc(suggestionId).collection('swipes').doc(currentUser.uid).set({
      'liked': liked,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMatchesStream(String partnerUid) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not signed in');
    return _firestore
        .collection('suggestions')
        .where('matches', arrayContains: [currentUser.uid, partnerUid])
        .snapshots();
  }
}
