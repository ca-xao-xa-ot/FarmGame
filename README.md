# 🌾 Nông Trại Xanh 

## 📖 Giới Thiệu

**Nông Trại Xanh** là game nông trại 2D viết bằng Flutter, lấy cảm hứng từ phong cách *Stardew Valley*.
Người chơi tiếp nhận mảnh đất từ bà ngoại, dần dần xây dựng nông trại, chăm sóc vật nuôi, câu cá, hoàn thành nhiệm vụ hằng ngày và leo cấp để mở khóa cây trồng & vật nuôi mới.


## 👨‍💻 Thông tin sinh viên

Dự án được phát triển bởi nhóm 2 thành viên:
- **Nguyễn Thị Thu Giang** - 23010871
- **Ngô Thị Minh Phương**  - 23012156

### 🎨 UI/UX Cải tiến
- **Auth Screen**: Giao diện đăng nhập/đăng ký hoàn toàn mới - cute pastel với hiệu ứng nổi bồng bềnh
  - Xóa chữ "v9-cloud save" và thông báo hạn chế tài khoản
  - Background động với hoa, sao lấp lánh
  - Button gradient đẹp với shadow glow
- **Intro/NPC Screen**: NPC bà nội dễ thương với animation bounce
  - Speech bubble với progress dots
  - Background scene có nhà, cây, mây động
  - Name input card cute với gradient
- **Game Screen**: Nút FAB gradient nhiều màu theo chức năng
  - Toast notification đẹp hơn với gradient xanh
  - Fishing overlay với border phát sáng
  - D-pad không đổi (đã tốt)
- **HUD**: Gradient glass-morphism, EXP bar với glow effect
  - Badge level vàng, badge ngày theo thời gian (ngày/đêm)
  - Inventory chips chỉ hiện khi có vật phẩm
- **Toolbar**: Gradient background, nút tool được chọn có glow vàng
- **Shop**: Header gradient xanh đẹp, seed card màu pastel theo loại cây
  - Badge MỚI / HIẾM, animal card màu theo loại

### 🌱 Cây Trồng Mới (5 loại)
- 🫐 **Việt Quất** - Lv 16, 70xu hạt, 180xu thu hoạch
- 🍑 **Đào** - Lv 20, 65xu hạt, 160xu thu hoạch
- 💜 **Oải Hương** - Lv 14, 50xu hạt, 130xu thu hoạch
- 🌶️ **Ớt** - Lv 11, 45xu hạt, 115xu thu hoạch
- 🥬 **Bắp Cải** - Lv 3, 25xu hạt, 70xu thu hoạch

### 🐾 Vật Nuôi Mới (3 loài)
- 🐴 **Ngựa** - Lv 25, 450xu, cho Sữa ngựa 🥛 (150xu/lần)
- 🦚 **Công** - Lv 22, 380xu, cho Lông đuôi  (130xu/lần)
- 🦃 **Gà Tây** - Lv 12, 200xu, cho Trứng lớn 🥚 (55xu/lần)

### 🏠 Ngôi Nhà Nâng Cấp
- **Bếp Nấu** 🍳: Nấu 5 món ăn với buff khác nhau
  - Salad Tươi → +10% tốc độ thu hoạch
  - Canh Rau → +20 năng lượng
  - Bánh Dâu → +50 EXP thưởng
  - Bí Ngô Nướng → +100 vàng
  - Sữa Mật Ong → +30% năng suất vật nuôi
- **Kệ Sách** 📚: Xem mẹo chơi hay
- **Tivi** 📺: Bản tin nông trại vui
- **Bể Cá** 🐠: Trang trí đẹp
- **Mèo Kitty** 🐱: Vuốt ve nhận thông điệp cute
- **Chậu Hoa** 🌺: Trang trí nhà
- **Nhạc Nền** 🎵: Bật/tắt nhạc từ trong nhà
- **Thống Kê** 📊: Xem stats ngay trong nhà

## Cách chạy
```bash
flutter run
```

## Công nghệ
- Flutter + Firebase Firestore (cloud save)
- Provider state management
- CustomPainter for farm rendering
