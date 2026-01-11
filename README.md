# Nhom6_Giang_Phuong
# Game Nông Trại 2D Cơ Bản (Flutter)
## Giới thiệu
Dự án **Game Nông Trại 2D Cơ Bản** là một mini game 2D chạy trên nền tảng Android, được xây dựng bằng Flutter kết hợp với game engine Flame.  
Game hướng đến lối chơi đơn giản, trực quan, giúp người chơi làm quen với các cơ chế cơ bản của game nông trại như di chuyển nhân vật, trồng cây, chăm sóc và thu hoạch để nhận điểm/coin.

Dự án phục vụ mục đích học tập, rèn luyện tư duy game logic và kỹ năng phát triển game 2D với Flutter.

---

## Mục tiêu đề tài
- Xây dựng một mini game nông trại 2D đơn giản
- Nhân vật có thể di chuyển tự do trên bản đồ
- Trồng và thu hoạch các loại cây cơ bản
- Vòng chơi ngắn gọn, dễ hiểu, dễ mở rộng

---

## Công nghệ sử dụng
- **Ngôn ngữ:** Dart  
- **Framework:** Flutter  
- **Game Engine:** Flame  
- **IDE:** Android Studio  
- **Tài nguyên:** Sprite 2D (Sprout Lands style)

---

## Chức năng chính

### 🌱 Hệ thống nông trại
- Bản đồ nông trại 2D dạng lưới (grid)
- Các ô đất trống dùng để trồng cây
- Mua và mở rộng ô đất bằng coin

### 🚶‍♂️ Nhân vật
- Di chuyển 4 hướng (lên, xuống, trái, phải)
- Có va chạm, không đi xuyên:
  - Cây trồng
  - Nhà
  - Mép bản đồ

### 🌾 Trồng trọt & thu hoạch
- Trồng cây tại ô đất trống
- Cây phát triển theo thời gian
- Thu hoạch để nhận điểm / coin
- Nhiều loại cây:
  - Cây phát triển nhanh (1 ngày)
  - Cây phát triển chậm (2–3 ngày)

### 💰 Điểm / Coin
- Nhận coin sau khi thu hoạch
- Coin dùng để:
  - Mua hạt giống
  - Mở ô đất mới

### 🎒 Kho đồ (Inventory đơn giản)
- Lưu trữ số lượng hạt giống
- Lưu trữ nông sản thu hoạch
- Dạng danh sách + số lượng

---

## Chức năng nâng cao (nếu có thời gian)

### 💧 Tưới nước
- Sau khi trồng cây phải tưới nước
- Nếu không tưới → cây không phát triển
- Tăng chiều sâu logic gameplay

### 🔊 Âm thanh cơ bản
- Âm thanh bước chân
- Âm thanh trồng cây
- Âm thanh thu hoạch
- Giúp game sinh động và có cảm giác thật hơn

---

## Định hướng phát triển
- Mở rộng thêm nhiều loại cây trồng
- Thêm NPC hoặc nhiệm vụ đơn giản
- Lưu trạng thái game
- Nâng cấp giao diện và hiệu ứng

---

## Ghi chú
Dự án tập trung vào các chức năng cốt lõi, dễ triển khai, phù hợp cho sinh viên mới học Flutter + Flame và lập trình game 2D cơ bản.

---

📱 **Nền tảng:** Android  
🎮 **Thể loại:** Mini game – Nông trại 2D  
