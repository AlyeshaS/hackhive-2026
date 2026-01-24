import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PartnerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> linkPartnerByEmail(String partnerEmail) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not signed in');
    await _firestore.collection('partners').doc(currentUser.uid).set({
      'userEmail': currentUser.email,
      'partnerEmail': partnerEmail,
    });
    // Optionally, set the reverse link for the partner
    final partnerQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: partnerEmail)
        .get();
    if (partnerQuery.docs.isNotEmpty) {
      final partnerId = partnerQuery.docs.first.id;
      await _firestore.collection('partners').doc(partnerId).set({
        'userEmail': partnerEmail,
        'partnerEmail': currentUser.email,
      });
    }
  }

  Future<String?> getPartnerEmail() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    final doc = await _firestore.collection('partners').doc(currentUser.uid).get();
    return doc.exists ? doc['partnerEmail'] as String : null;
  }
}
