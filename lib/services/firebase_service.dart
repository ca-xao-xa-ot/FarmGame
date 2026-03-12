import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  
  Future<void> initUserData() async {
    if (currentUserId == null) return;
    DocumentReference userRef = _db.collection('users').doc(currentUserId);
    DocumentSnapshot snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'email': _auth.currentUser?.email ?? 'Nông dân Ẩn danh',
        'displayName': _auth.currentUser?.displayName ?? 'Nông dân',
        'gold': 100,
        'level': 1,
        'inventory': [], 
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<DocumentSnapshot> getUserDataStream() {
    if (currentUserId == null) return const Stream.empty();
    return _db.collection('users').doc(currentUserId).snapshots();
  }

  Future<void> updateGold(int amount) async {
    if (currentUserId == null) return;
    await _db.collection('users').doc(currentUserId).update({
      'gold': FieldValue.increment(amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getTopFarmers() {
    return _db.collection('users')
        .orderBy('gold', descending: true)
        .limit(10)
        .snapshots();
  }

  
  Future<bool> buyItem(String itemEmoji, int price) async {
    if (currentUserId == null) return false;
    DocumentReference userRef = _db.collection('users').doc(currentUserId);

    
    return await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return false;

      int currentGold = snapshot.get('gold') ?? 0;
      if (currentGold >= price) {
        
        transaction.update(userRef, {
          'gold': currentGold - price,
          'inventory': FieldValue.arrayUnion([itemEmoji]), 
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        return true; 
      } else {
        return false; 
      }
    });
  }
}