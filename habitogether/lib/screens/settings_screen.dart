import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/user_provider.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Cài đặt',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF281B30), Color(0xFF1D1340)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animationController.value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - _animationController.value) * 30),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Phần tài khoản
                    _buildSectionTitle('Tài khoản'),
                    const SizedBox(height: 12),

                    _buildSettingItem(
                      title: 'Thông tin cá nhân',
                      icon: FontAwesomeIcons.userCircle,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/profile');
                      },
                    ),

                    _buildSettingItem(
                      title: 'Đổi mật khẩu',
                      icon: FontAwesomeIcons.lock,
                      onTap: () {
                        // Xử lý khi nhấp vào đổi mật khẩu
                      },
                    ),

                    const SizedBox(height: 32),

                    // Phần ứng dụng
                    _buildSectionTitle('Ứng dụng'),
                    const SizedBox(height: 12),

                    _buildSettingItem(
                      title: 'Ngôn ngữ',
                      icon: FontAwesomeIcons.language,
                      onTap: () {
                        _showLanguageBottomSheet(context);
                      },
                      trailing: Text(
                        MyApp.of(context)?.locale.languageCode == 'vi'
                            ? 'Tiếng Việt'
                            : 'English',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),

                    _buildSettingItem(
                      title: 'Thông báo',
                      icon: FontAwesomeIcons.bell,
                      onTap: () {
                        // Xử lý khi nhấp vào thông báo
                      },
                    ),

                    _buildSwitchSettingItem(
                      title: 'Âm thanh',
                      icon: FontAwesomeIcons.volumeHigh,
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                      },
                    ),

                    _buildSwitchSettingItem(
                      title: 'Chế độ tối',
                      icon: FontAwesomeIcons.moon,
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Phần khác
                    _buildSectionTitle('Khác'),
                    const SizedBox(height: 12),

                    _buildSettingItem(
                      title: 'Về chúng tôi',
                      icon: FontAwesomeIcons.circleInfo,
                      onTap: () {
                        // Xử lý khi nhấp vào về chúng tôi
                      },
                    ),

                    _buildSettingItem(
                      title: 'Điều khoản dịch vụ',
                      icon: FontAwesomeIcons.fileContract,
                      onTap: () {
                        // Xử lý khi nhấp vào điều khoản dịch vụ
                      },
                    ),

                    _buildSettingItem(
                      title: 'Chính sách bảo mật',
                      icon: FontAwesomeIcons.shieldHalved,
                      onTap: () {
                        // Xử lý khi nhấp vào chính sách bảo mật
                      },
                    ),

                    const SizedBox(height: 40),

                    // Nút đăng xuất
                    _buildLogoutButton(userProvider),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFF9F43),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Widget hiển thị một mục cài đặt
  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFFF9F43).withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: const Color(0xFFFF9F43), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  trailing ??
                      const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị một mục cài đặt có công tắc
  Widget _buildSwitchSettingItem({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFF9F43), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFFFF9F43),
              activeTrackColor: const Color(0xFFFF9F43).withOpacity(0.3),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  // Widget nút đăng xuất
  Widget _buildLogoutButton(UserProvider userProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutDialog(context, userProvider);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 8,
          shadowColor: Colors.red.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.rightFromBracket, size: 18),
            SizedBox(width: 12),
            Text(
              'Đăng xuất',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị hộp thoại xác nhận đăng xuất
  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFF2C1D56),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Bạn có chắc chắn muốn đăng xuất không?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Hủy',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Xóa dữ liệu người dùng
                  userProvider.clearUserData();
                  
                  // Đóng dialog
                  Navigator.pop(context);

                  // Đóng tất cả màn hình và quay về trang đăng nhập
                  // Dùng context của scaffold (đóng tất cả context con)
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Hiển thị bottom sheet chọn ngôn ngữ
  void _showLanguageBottomSheet(BuildContext context) {
    final app = MyApp.of(context);
    final currentLocale = app?.locale.languageCode ?? 'vi';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A236A), Color(0xFF2C1D56)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Chọn ngôn ngữ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildLanguageOption(
                  context,
                  'Tiếng Việt',
                  'vi',
                  currentLocale == 'vi',
                  app,
                ),
                _buildLanguageOption(
                  context,
                  'English',
                  'en',
                  currentLocale == 'en',
                  app,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  // Widget hiển thị một tùy chọn ngôn ngữ
  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    String code,
    bool isSelected,
    MyAppState? app,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          app?.changeLocale(Locale(code));
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFFFF9F43).withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.05),
        child: Ink(
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Colors.white.withOpacity(0.15)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  code == 'vi' ? '🇻🇳' : '🇺🇸',
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFFF9F43),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
