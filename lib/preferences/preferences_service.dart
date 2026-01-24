import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> savePreferences(Map<String, dynamic> preferences) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not signed in');
    await _firestore
        .collection('preferences')
        .doc(currentUser.uid)
        .set(preferences);
  }

  Future<Map<String, dynamic>?> getPreferences() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    final doc = await _firestore
        .collection('preferences')
        .doc(currentUser.uid)
        .get();
    return doc.exists ? doc.data() : null;
  }
}
