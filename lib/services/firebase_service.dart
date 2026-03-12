import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Khởi tạo dữ liệu người chơi mới
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
        'inventory': [], // Thêm cái balo (Kho đồ) trống để đựng vật phẩm
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

  // TÍNH NĂNG MỚI: Mua vật phẩm từ Cửa Hàng
  Future<bool> buyItem(String itemEmoji, int price) async {
    if (currentUserId == null) return false;
    DocumentReference userRef = _db.collection('users').doc(currentUserId);

    // Dùng Transaction để đảm bảo an toàn: Phải đủ tiền mới cho mua
    return await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return false;

      int currentGold = snapshot.get('gold') ?? 0;
      if (currentGold >= price) {
        // Đủ tiền -> Trừ tiền và Thêm đồ vào kho
        transaction.update(userRef, {
          'gold': currentGold - price,
          'inventory': FieldValue.arrayUnion([itemEmoji]), // Nét đồ vào balo
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        return true; // Mua thành công
      } else {
        return false; // Không đủ tiền
      }
    });
  }
}