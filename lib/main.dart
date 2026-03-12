import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'providers/game_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FarmGameApp());
}

class FarmGameApp extends StatelessWidget {
  const FarmGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Nếu vào game vẫn thấy nền xanh không có cây cối, hãy thử đổi dòng dưới thành:
      // create: (context) => GameProvider()..init(),
      create: (context) => GameProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nông Trại Xanh',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const AuthScreen(),
      ),
    );
  }
}