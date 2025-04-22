import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:habitogether/l10n/app_localizations.dart';
import 'signup_screen.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../providers/pet_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đảm bảo widget được rebuild khi ngôn ngữ thay đổi
    final AppLocalizations? t = AppLocalizations.of(context);
    if (t == null) return;
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void validateAndSubmit() async {
    if (!mounted) return; // Kiểm tra widget có còn mounted không

    final AppLocalizations? t = AppLocalizations.of(context);
    if (t == null) return;

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) showErrorDialog(t.emptyFields);
      return;
    }

    if (!RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
    ).hasMatch(email)) {
      if (mounted) showErrorDialog(t.invalidEmail);
      return;
    }

    if (password.length < 8) {
      if (mounted) showErrorDialog(t.shortPassword);
      return;
    }

    if (_isLoading) return; 
    setState(() => _isLoading = true);
    
    try {
      final authService = AuthService();
      final response = await authService.login(
        email,
        password,
        MyApp.of(context)?.locale.languageCode ?? 'en',
      );

      if (!mounted) return;

      if (response['success'] == true) {
        // Kiểm tra xem có ID không
        if (!response.containsKey('id')) {
          showErrorDialog('Lỗi: Không thể lấy thông tin user. Vui lòng thử lại sau.');
          return;
        }

        final userId = response['id'];

        // Lưu thông tin user
        try {
          context.read<UserProvider>().setUserData(
            id: userId,
            fullName: response['fullName'] ?? '',
            email: response['email'] ?? '',
            avatar: response['avatar'] ?? '',
          );

          // Load pets của user
          await context.read<PetProvider>().loadPets(userId);

          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/home');
        } catch (e) {
          showErrorDialog('Lỗi: Không thể xử lý thông tin user. Vui lòng thử lại sau.');
        }
      } else {
        showErrorDialog(response['message'] ?? t.loginFailed);
      }
    } catch (e) {
      if (mounted) showErrorDialog('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final AppLocalizations? t = AppLocalizations.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF2C1D56),
          title: Text(
            t?.error ?? 'Error !',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                t?.ok ?? 'OK',
                style: const TextStyle(
                  color: Color(0xFFFF9F43),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _socialLoginButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.15 * 255).round()),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 30),
        onPressed: onPressed,
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? t = AppLocalizations.of(context);
    if (t == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF281B30), Color(0xFF1D1340)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  PopupMenuButton<Locale>(
                    icon: const Icon(Icons.language, color: Colors.white),
                    onSelected: (Locale value) {
                      Locale newLocale = Locale(
                        value.languageCode,
                        value.countryCode,
                      );
                      MyApp.of(context)?.changeLocale(newLocale);
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: Locale('en', ''),
                            child: Text('🇺🇸 English'),
                          ),
                          const PopupMenuItem(
                            value: Locale('vi', ''),
                            child: Text('🇻🇳 Tiếng Việt'),
                          ),
                        ],
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // Logo với animation scale
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Image.asset(
                                'assets/logo.png',
                                height: 150,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Chào mừng
                        Text(
                          t.welcomeToFitleveling,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 6,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Form đăng nhập trong card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3A236A), Color(0xFF2C1D56)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            children: [
                              // Email field
                              TextField(
                                controller: emailController,
                                focusNode: emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: t.email,
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.white70,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: Colors.white60,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Password field
                              TextField(
                                controller: passwordController,
                                focusNode: passwordFocusNode,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: t.password,
                                  prefixIcon: const Icon(
                                    FontAwesomeIcons.lock,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? FontAwesomeIcons.eyeSlash
                                          : FontAwesomeIcons.eye,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () =>
                                            _obscurePassword =
                                                !_obscurePassword,
                                      );
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: Colors.white60,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                              
                              // "Quên mật khẩu?" button
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // Handle forgot password
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                  ),
                                  child: Text(
                                    t.forgotPassword,
                                    style: const TextStyle(
                                      color: Color(0xFFFF9F43),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 15),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF9F43),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    elevation: 8,
                                    shadowColor: const Color(
                                      0xFFFF9F43,
                                    ).withOpacity(0.5),
                                  ),
                                  onPressed:
                                      _isLoading ? null : validateAndSubmit,
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : Text(
                                            t.login,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
  
                        // Divider "hoặc đăng nhập với"
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Colors.white30,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  t.orLoginWith,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Colors.white30,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 25),
                        
                        // Social login buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialLoginButton(
                              icon: FontAwesomeIcons.google,
                              color: Colors.red,
                              onPressed: () {},
                            ),
                            const SizedBox(width: 20),
                            _socialLoginButton(
                              icon: FontAwesomeIcons.facebook,
                              color: Colors.blue,
                              onPressed: () {},
                            ),
                            const SizedBox(width: 20),
                            _socialLoginButton(
                              icon: FontAwesomeIcons.apple,
                              color: Colors.white,
                              onPressed: () {},
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),

                        // "Đăng ký ngay"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.alreadyHaveAccount,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const SignupScreen(),
                                    ),
                                  ),
                              child: Text(
                                t.signUpNow,
                                style: const TextStyle(
                                  color: Color(0xFFFF9F43),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}