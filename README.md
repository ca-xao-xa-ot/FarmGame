# 🌾 Nông Trại Xanh (FarmGame)
---

## 📖 Giới Thiệu

**Nông Trại Xanh** là game nông trại 2D viết bằng Flutter, lấy cảm hứng từ phong cách *Stardew Valley*.
Người chơi tiếp nhận mảnh đất từ bà ngoại, dần dần xây dựng nông trại, chăm sóc vật nuôi, câu cá, hoàn thành nhiệm vụ hằng ngày và leo cấp để mở khóa cây trồng & vật nuôi mới.

| 🎯 Thể loại | 🛠️ Công nghệ | 🖥️ Nền tảng |
|---|---|---|
| Nông trại 2D / Casual | Flutter · Dart · Firebase | Windows · Android · (iOS · Web) |

---
## 👨‍💻 Thông tin sinh viên

Dự án được phát triển bởi nhóm 2 thành viên:
- **Nguyễn Thị Thu Giang** - 23010871
- **Ngô Thị Minh Phương** - 23010


## ✨ Tính Năng Nổi Bật

| # | Tính năng | Chi tiết |
|---|---|---|
| 1 | 🗺️ **Bản đồ 20×15** | Farm grid với ao cá, bút nhốt vật nuôi, ngôi nhà, đồng ruộng |
| 2 | 🌱 **5 loại cây trồng** | Lúa · Cà Chua · Dâu Tây · Cà Rốt · Cà Tím (mở khóa theo cấp) |
| 3 | 🐾 **4 loại vật nuôi** | Gà · Vịt · Bò · Lợn (mua tại cửa hàng, tự roam trong bút) |
| 4 | 🎣 **Câu cá** | Mini-game 5 giây, bán cá tại Animal Panel |
| 5 | ⭐ **Hệ thống Level (1–100)** | EXP từ mọi hành động, mở khóa cây & vật nuôi mới |
| 6 | 📋 **3 Nhiệm vụ hằng ngày** | Tự động tạo mới mỗi ngày, thưởng EXP + vàng |
| 7 | 📖 **Nhật ký nông trại** | Ghi lại sự kiện mỗi ngày |
| 8 | 🎵 **11 âm thanh + BGM** | Ngày/đêm riêng, SFX low-latency |
| 9 | ☁️ **Firebase Auth + Firestore** | Đăng nhập Google / Email, lưu cloud |
| 10 | 💾 **Local Save** | SharedPreferences (offline fallback) |
| 11 | 🕹️ **D-Pad ảo + Bàn phím** | Hỗ trợ cả touch và keyboard |

---

## 🚀 Cài Đặt & Chạy Nhanh

### Yêu cầu
- Flutter SDK `>=3.3.0 <4.0.0`
- Dart SDK `>=3.3.0`
- Firebase project (Google/Email auth + Firestore đã bật)

### Bước 1 – Clone / giải nén project
```bash
cd FarmGame
flutter pub get
```

### Bước 2 – Cấu hình Firebase
```bash
# Cài FlutterFire CLI (nếu chưa có)
dart pub global activate flutterfire_cli

# Kết nối Firebase project của bạn
flutterfire configure
```
> File `lib/firebase_options.dart` sẽ được tạo tự động.

### Bước 3 – Chạy game

```bash
# Windows Desktop
flutter create . --platforms=windows   # chỉ chạy 1 lần
flutter run -d windows

# Android
flutter run -d android

# Web (thử nghiệm)
flutter run -d chrome
```

---

## 🎮 Điều Khiển

### Bàn phím
| Phím | Hành động |
|------|-----------|
| `W` `A` `S` `D` hoặc `↑` `↓` `←` `→` | Di chuyển nhân vật |
| `E` hoặc `Space` | Tương tác ô đất phía trước |
| `1` | Công cụ: 🖐️ Tay (trồng / thu hoạch) |
| `2` | Công cụ: ⛏️ Cuốc (xới đất) |
| `3` | Công cụ: 💧 Bình tưới |
| `4` | Công cụ: 🎣 Cần câu |
| `F` | Đi ngủ → sang ngày mới |
| `H` | Vào / ra nhà |

### Màn hình cảm ứng
| UI | Chức năng |
|----|-----------|
| D-Pad trái | Di chuyển |
| Nút công cụ (toolbar dưới) | Chọn công cụ |
| Tap ô đất | Tương tác theo công cụ đang chọn |
| Nút 🐾 **Nuôi** | Mở/đóng panel vật nuôi |
| Nút 📋 **Nhiệm vụ** | Mở/đóng panel quest hôm nay |
| Nút 🏠 **Nhà** | Vào nhà |
| Nút 🛍️ **Cửa hàng** | Mở shop mua hạt giống & vật nuôi |

---

## 🌱 Gameplay Chi Tiết

### Vòng lặp ngày
```
Sáng thức dậy (gà gáy 🐓)
    ↓
Cuốc đất ⛏️ → Gieo hạt 🌱 → Tưới nước 💧
    ↓
Cho vật nuôi ăn 🌽 → Thu sản phẩm 🥚🥛
    ↓
Câu cá 🎣 → Bán cá 🪙
    ↓
Thu hoạch 🌾 → Bán / lên cấp ⭐
    ↓
Vào nhà → Ngủ 🛏️ → Ngày mới
```

### Cây trồng
| Cây     | Emoji | Giá hạt | Giá bán | Unlock Lv | Thời gian |
|-----    |-------|---------|---------|-----------|-----------|
| Lúa     | 🌾   | 20xu    | 60xu     | 1        | 2 ngày |
| Cà Rốt  | 🥕   | 30xu    | 80xu     | 19       | 2 ngày |
| Cà Chua | 🍅   | 40xu    | 100xu    | 7        | 2 ngày |
| Cà Tím  | 🍆   | 50xu    | 120xu    | 25       | 2 ngày |
| Dâu Tây | 🍓   | 60xu    | 150xu    | 13       | 2 ngày |

### Vật nuôi
| Loại | Emoji | Giá mua | Cho ăn | Sản phẩm | Giá sp | Unlock Lv | Max |
|------|-------|---------|--------|----------|--------|-----------|-----|
| Gà   | 🐔    | 80xu   | 10xu | Trứng 🥚    | 25xu   | 2         | 5 |
| Vịt  | 🦆    | 120xu  | 12xu | Trứng vịt 🥚| 30xu   | 5         | 5 |
| Bò   | 🐄    | 200xu  | 20xu | Sữa 🥛      | 50xu   | 10        | 3 |
| Lợn  | 🐷    | 260xu  | 25xu | Thịt heo 🥩| 90xu    | 15        | 3 |

> Vật nuôi cần được nuôi lớn (baby → adult) trước khi cho sản phẩm.
> Mỗi ngày chỉ sản xuất 1 lần.

### Câu cá
- Đứng cạnh ao (góc trái-dưới), chọn công cụ 🎣 → tap ao
- Mini-game đếm ngược **5 giây**, phát âm thanh ngẫu nhiên (fishing1/2/3)
- Câu xong → panel vật nuôi tự mở → tab bán cá → **+30xu/con**

---

## 📋 Hệ Thống Nhiệm Vụ & Thành Tích

### Nhiệm Vụ Hằng Ngày (3 quest/ngày)
Tự động tạo mới mỗi ngày, ngẫu nhiên từ 6 loại:

| Icon | Loại | Ví dụ |
|------|------|-------|
| 🌾 | Thu hoạch | Thu hoạch 3 cây |
| 💧 | Tưới nước | Tưới 5 ô đất |
| 🌽 | Cho ăn | Cho 2 con ăn |
| 🎣 | Câu cá | Câu được 2 con cá |
| ⛏️ | Xới đất | Xới 4 ô đất |
| 🪙 | Kiếm vàng | Kiếm 200 vàng |

---

## 🎵 Âm Thanh

Tất cả file MP3 đặt trong `assets/audio/`:

| File | Mô tả | Kích hoạt khi |
|------|-------|---------------|
| `water.mp3` | Tiếng nước tưới | Tưới nước cây |
| `hoe.mp3` | Tiếng cuốc đất + gieo hạt | Cuốc đất & gieo hạt |
| `feed.mp3` | Tiếng cho ăn (munch) | Cho vật nuôi ăn |
| `coins.mp3` | Tiếng xu vàng | Thu hoạch / bán đồ |
| `fishing1.mp3` | Tiếng câu cá – ver 1 | Câu cá (ngẫu nhiên) |
| `fishing2.mp3` | Tiếng câu cá – ver 2 | Câu cá (ngẫu nhiên) |
| `fishing3.mp3` | Tiếng câu cá – ver 3 | Câu cá (ngẫu nhiên) |
| `rooster.mp3` | Tiếng gà gáy | Mỗi sáng ngày mới |
| `sleep.mp3` | Tiếng gió nhẹ / tắt đèn | Nhấn nút ngủ 🌙 |
| `day_bgm.mp3` | Nhạc nền ban ngày (loop) | Suốt thời gian chơi ban ngày |
| `night_bgm.mp3` | Nhạc nền ban đêm (loop) | Khi chuyển đêm → ngày |

> ℹ️ Nếu thiếu file MP3, game vẫn chạy bình thường (silent fallback).

---

## 📁 Cấu Trúc Project

```
FarmGame/
├── lib/
│   ├── main.dart                        # Entrypoint, Firebase init
│   ├── firebase_options.dart            # Firebase config (auto-gen)
│   ├── models/
│   │   └── game_models.dart             # TileModel, AnimalModel, PlayerModel,
│   │                                    # DailyQuest, QuestType, Achievements
│   ├── providers/
│   │   └── game_provider.dart           # Game logic v8 (state, physics, quests)
│   ├── services/
│   │   ├── audio_service.dart           # AudioService v9 (11 SFX + BGM)
│   │   ├── auth_service.dart            # Firebase Auth (Email + Google)
│   │   ├── firebase_service.dart        # Firestore read/write
│   │   └── local_storage_service.dart   # SharedPreferences (offline save)
│   ├── screens/
│   │   ├── auth_screen.dart             # Đăng nhập / đăng ký
│   │   ├── intro_screen.dart            # Màn hình nhập tên (NPC bà ngoại)
│   │   ├── game_screen.dart             # Main farm (Ticker loop + panels)
│   │   ├── farm_screen.dart             # Canvas farm sub-screen
│   │   └── house_screen.dart            # Nội thất nhà (giường, nhật ký)
│   └── widgets/
│       ├── farm_painter.dart            # CustomPainter vẽ bản đồ farm
│       ├── hud_widget.dart              # HUD: tên, cấp, vàng, ngày, EXP bar
│       ├── toolbar_widget.dart          # Thanh công cụ dưới màn hình
│       ├── animal_panel.dart            # Panel vật nuôi + bán cá
│       ├── quest_panel.dart             # Panel nhiệm vụ hôm nay
│       ├── shop_dialog.dart             # Cửa hàng hạt giống & vật nuôi
│       ├── diary_dialog.dart            # Nhật ký nông trại
│       ├── achievement_dialog.dart      # Danh sách thành tích
│       └── leaderboard_dialog.dart      # Bảng xếp hạng (Firebase)
├── assets/
│   ├── audio/                           # 11 file MP3 (xem bảng Âm Thanh)
│   ├── images/                          # Sprite / icon ảnh
│   └── fonts/                           # Font chữ tùy chỉnh
├── pubspec.yaml
└── README.md
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:            sdk: flutter
  provider:           ^6.1.2      # State management
  shared_preferences: ^2.3.2      # Local save / load
  uuid:               ^4.5.1      # Animal / entity unique ID
  audioplayers:       ^6.0.0      # SFX + BGM playback
  firebase_core:      ^3.1.1      # Firebase core
  firebase_auth:      ^5.1.2      # Auth (Email + Google)
  cloud_firestore:    ^5.0.2      # Cloud save / leaderboard
  google_sign_in:     ^6.2.1      # Google OAuth
```

---

## 🏗️ Kiến Trúc

```
AuthScreen
    └── IntroScreen (NPC dialog + nhập tên)
            └── GameScreen (main loop)
                    ├── FarmPainter       ← Canvas render
                    ├── HudWidget         ← HUD overlay
                    ├── ToolbarWidget     ← Chọn công cụ
                    ├── AnimalPanelWidget ← Nuôi + bán cá
                    ├── QuestPanelWidget  ← Nhiệm vụ hôm nay
                    └── HouseScreen       ← Vào nhà / ngủ
```

**State Flow:**
```
GameProvider (ChangeNotifier)
    ├── PlayerModel  ← level, exp, gold, quests, achievements
    ├── List<TileModel>  ← 300 ô đất (20×15)
    ├── List<AnimalModel>  ← vật nuôi + AI roaming
    └── AudioService  ← SFX + BGM manager
```

---

## ⚙️ Hằng Số Quan Trọng (`utils/constants.dart`)

| Hằng số | Giá trị | Ý nghĩa |
|---------|---------|---------|
| `farmCols × farmRows` | 20 × 15 | Kích thước bản đồ |
| `tileSize` | 52.0 px | Kích thước 1 ô |
| `maxLevel` | 100 | Cấp tối đa |
| `startGold` | 500🪙 | Vàng ban đầu |
| `fishingSeconds` | 5 s | Thời gian câu cá |
| `fishGoldValue` | 30🪙 | Giá bán 1 con cá |
| `playerMaxSpd` | 6.5 | Tốc độ di chuyển tối đa |
| `expToNextLevel` | `60 + (lv-1)*25 + (lv-1)²*2` | EXP cần để lên cấp (tối đa 5000) |

---

## 🔥 Firebase Setup

1. Tạo project tại [Firebase Console](https://console.firebase.google.com)
2. Bật **Authentication** → Email/Password + Google Sign-In
3. Bật **Cloud Firestore** (test mode hoặc cấu hình rules)
4. Chạy `flutterfire configure` trong thư mục project
5. Build lại: `flutter pub get && flutter run`

---

## 🐛 Troubleshooting

| Vấn đề | Giải pháp |
|--------|-----------|
| Không có âm thanh | Kiểm tra file MP3 trong `assets/audio/`; đảm bảo khai báo trong `pubspec.yaml` |
| Câu cá không có âm thanh | Kiểm tra `fishing1.mp3`, `fishing2.mp3`, `fishing3.mp3` tồn tại |
| Firebase lỗi | Chạy lại `flutterfire configure`; kiểm tra `firebase_options.dart` |
| Màn hình xanh không có farm | Trong `main.dart`, đổi thành `GameProvider()..init()` |
| Android lỗi build | Kiểm tra `minSdkVersion >= 21` trong `android/app/build.gradle` |
| Audio lag trên Android | AudioService dùng `PlayerMode.lowLatency` cho SFX – nếu vẫn lag thử `PlayerMode.mediaPlayer` |

---

## 🗺️ Roadmap

- [ ] 🏪 Mở rộng cửa hàng (bán sản phẩm chế biến)
- [ ] 🌧️ Hệ thống thời tiết (mưa tự động tưới)
- [ ] 👥 Multiplayer / coop farm
- [ ] 🎪 Lễ hội mùa vụ hằng tháng
- [ ] 📊 Thống kê chi tiết (biểu đồ thu nhập)
- [ ] 🌍 Bản đồ mở rộng (unlock vùng đất mới)

---

## 📄 License

Dự án cá nhân / học tập. Không sử dụng cho mục đích thương mại khi chưa có sự đồng ý của tác giả.

---

<div align="center">



</div>
