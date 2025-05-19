# HabiTogether

**HabiTogether** là ứng dụng xây dựng thói quen, phát triển bản thân và rèn luyện sức khỏe thông qua hệ thống nhiệm vụ, phần thưởng và thú cưng ảo. Ứng dụng được phát triển bằng Flutter, hỗ trợ đa nền tảng (Android, iOS, Web, Desktop) và có backend Node.js sử dụng MongoDB.

---

## 🌟 Tính năng nổi bật
- Quản lý thói quen, nhiệm vụ cá nhân hàng ngày.
- Theo dõi tiến trình luyện tập, sức khỏe, học tập...
- Hệ thống thú cưng ảo: nhận, nuôi, nâng cấp và tương tác với thú cưng.
- Nhận điểm thưởng, phần thưởng khi hoàn thành nhiệm vụ.
- Hỗ trợ đa ngôn ngữ (Tiếng Việt, Tiếng Anh).
- Đăng ký, đăng nhập, bảo mật tài khoản.
- Giao diện hiện đại, dễ sử dụng.
- Hỗ trợ thông báo nhắc nhở.

---

## 🚀 Hướng dẫn cài đặt
### Yêu cầu
- Flutter SDK (>=3.0)
- Node.js (>=14)
- MongoDB (local hoặc cloud)

### Cài đặt Frontend (Flutter)
```bash
cd habitogether
flutter pub get
flutter run
```

### Cài đặt Backend
```bash
cd habitogether_backend
npm install
node src/server.js
```

> Đảm bảo đã cấu hình chuỗi kết nối MongoDB trong file `.env` hoặc trực tiếp trong code backend.

---

## 📁 Cấu trúc thư mục
```
habitogether/           # Mã nguồn Flutter app
habitogether_backend/   # Backend Node.js
```
- `lib/`               : Mã nguồn chính của ứng dụng Flutter
- `assets/`            : Hình ảnh, icon, dữ liệu tĩnh
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`: Mã nguồn build đa nền tảng
- `test/`              : Unit test

---

## 🤝 Đóng góp
Rất hoan nghênh mọi đóng góp cho dự án! Bạn có thể:
- Fork repository, tạo branch riêng và gửi pull request
- Báo lỗi hoặc đề xuất tính năng qua Issues
- Tham gia phát triển backend, frontend hoặc viết tài liệu

---

## 📞 Liên hệ
- Tác giả: **Lâm Thành Đức**
- Email: lamthanhduc2004@gmail.com
- Github: [lamthanhduc2004](https://github.com/lamthanhduc2004)

---

> Cảm ơn bạn đã quan tâm và sử dụng HabiTogether!
