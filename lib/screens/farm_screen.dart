import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import 'auth_screen.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key});

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _firebaseService.initUserData().then((_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _farmCorn() {
    _firebaseService.updateGold(10);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🌽 Thu hoạch thành công! +10 Vàng'), duration: Duration(milliseconds: 500)),
    );
  }

  void _logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  
  void _openShop(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('CỬA HÀNG NÔNG SẢN', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
                const SizedBox(height: 20),
                _buildShopItem('Bò Sữa', '🐄', 100),
                _buildShopItem('Cừu Lông Mịn', '🐑', 150),
                _buildShopItem('Cây Táo', '🍎', 200),
                _buildShopItem('Gà Đẻ Trứng', '🐔', 50),
              ],
            ),
          );
        }
    );
  }

  
  Widget _buildShopItem(String name, String emoji, int price) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 30)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Giá: $price Vàng', style: const TextStyle(color: Colors.orange)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
        onPressed: () async {
          bool success = await _firebaseService.buyItem(emoji, price);
          if (mounted) {
            Navigator.pop(context); 
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(success ? 'Mua $name thành công! $emoji' : 'Không đủ Vàng để mua $name! 😢')),
            );
          }
        },
        child: const Text('Mua', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.green)));

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Nông Trại Của Tôi'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Đăng xuất')
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              color: Colors.amber,
              child: const Text('🏆 TOP PHÚ NÔNG', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseService.getTopFarmers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  var docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: index == 0 ? Colors.amber : Colors.green[100],
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(data['displayName'] ?? 'Nông dân', style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text('${data['gold']} 💰', style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: _firebaseService.getUserDataStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var data = snapshot.data?.data() as Map<String, dynamic>?;
          int gold = data?['gold'] ?? 0;
          String name = data?['displayName'] ?? 'Nông dân';
          
          List<dynamic> inventory = data?['inventory'] ?? [];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Chào, $name!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 20),

                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber, width: 2)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 40),
                      const SizedBox(width: 10),
                      Text('$gold Vàng', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                
                Container(
                  width: 300,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.brown[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.brown, width: 3),
                  ),
                  child: inventory.isEmpty
                      ? const Center(child: Text('Nông trại đang trống.\nHãy vào cửa hàng mua thêm nhé!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))
                      : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: inventory.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(item.toString(), style: const TextStyle(fontSize: 40)),
                      )).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                
                ElevatedButton.icon(
                  onPressed: _farmCorn,
                  icon: const Text('🌽', style: TextStyle(fontSize: 30)),
                  label: const Text('Trồng Ngô & Thu Hoạch', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      backgroundColor: Colors.green, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                  ),
                ),

                const SizedBox(height: 20),

                
                ElevatedButton.icon(
                  onPressed: () => _openShop(context),
                  icon: const Icon(Icons.store, size: 30),
                  label: const Text('Vào Cửa Hàng', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      backgroundColor: Colors.amber, foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}