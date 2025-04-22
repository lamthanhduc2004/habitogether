import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // Lấy base URL dựa vào platform
  static String getApiUrl() {
    // Nếu đang chạy trên web
    if (kIsWeb) {
      return "http://localhost:5000";
    }
    // Nếu đang chạy trên Android
    else if (!kIsWeb && Platform.isAndroid) {
      // Sử dụng 10.0.2.2 để truy cập localhost của máy host từ máy ảo Android
      return "http://10.0.2.2:5000";
    }
    // Nếu đang chạy trên iOS
    else if (!kIsWeb && Platform.isIOS) {
      // Sử dụng localhost cho iOS simulator
      return "http://localhost:5000";
    }
    // Mặc định cho các platform khác
    else {
      return "http://localhost:5000";
    }
  }
}
