import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'pet_screen.dart';
import 'workout_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';
import '../providers/workout_provider.dart';
import '../providers/notification_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isBlinking = false;
  Timer? _blinkTimer;
  String? _token;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    // Giả sử bạn có một phương thức để lấy token từ AuthService
    setState(() {
      _token = "your_token_here"; // Thay thế bằng token thực
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isBlinking = true;
    });
    
    // Hủy timer cũ nếu có
    _blinkTimer?.cancel();

    // Đặt timer để tắt hiệu ứng nháy sau 150ms
    _blinkTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isBlinking = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WorkoutProvider(token: _token!),
        ),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF1D1340),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF281B30), Color(0xFF1D1340)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.black,
                          child: Icon(
                            FontAwesomeIcons.circleUser,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Consumer<NotificationProvider>(
                            builder: (context, notificationProvider, _) {
                              final unreadCount =
                                  notificationProvider.unreadCount;
                              return Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const NotificationScreen(),
                                        ),
                                      );
                                    },
                                    child: const CircleIcon(
                                      icon: FontAwesomeIcons.bell,
                                      color: Color(0xFFFF9F43),
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          unreadCount > 9
                                              ? '9+'
                                              : '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            child: const CircleIcon(
                              icon: FontAwesomeIcons.gear,
                              color: Color(0xFFFF9F43),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(child: _getScreenForIndex(_selectedIndex)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              List<IconData> icons = [
                FontAwesomeIcons.house,
                FontAwesomeIcons.dumbbell,
                FontAwesomeIcons.users,
                FontAwesomeIcons.trophy,
              ];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(5),
                child: IconButton(
                  icon: Icon(
                    icons[index],
                    color:
                        _selectedIndex == index
                            ? _isBlinking && _selectedIndex == index
                                ? Colors.white
                                : const Color(0xFFFF9F43)
                            : Colors.white30,
                    size: _selectedIndex == index ? 30 : 28,
                  ),
                  onPressed: () => _onItemTapped(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _getScreenForIndex(int index) {
    // Chỉ hiển thị màn hình thú cưng ở tab Home (index 0)
    switch (index) {
      case 0:
        return const PetScreen();
      case 1:
        return const WorkoutScreen();
      case 2:
        return _buildPlaceholderScreen(
          'Cộng đồng',
          'Chức năng cộng đồng đang được phát triển',
        );
      case 3:
        return _buildPlaceholderScreen(
          'Thành tích',
          'Chức năng thành tích đang được phát triển',
        );
      default:
        return const PetScreen();
    }
  }

  // Widget hiển thị nội dung tạm thời cho các tab khác
  Widget _buildPlaceholderScreen(String title, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.hourglassHalf, size: 80, color: Colors.amber),
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const CircleIcon({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.black,
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }
}