import 'package:habitogether/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'package:habitogether/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final FocusNode fullNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void validateAndSubmit() async {
    final AppLocalizations t = AppLocalizations.of(context)!;
    String fullName = fullNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    // Kiểm tra các trường không được để trống
    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showErrorDialog(t.emptyFields);
      return;
    }

    // Kiểm tra email hợp lệ
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      showErrorDialog(t.invalidEmail);
      return;
    }

    // Kiểm tra độ dài mật khẩu
    if (password.length < 8) {
      showErrorDialog(t.shortPassword);
      return;
    }

    // Kiểm tra mật khẩu khớp nhau
    if (password != confirmPassword) {
      showErrorDialog(t.passwordMismatch); 
      return;
    }

    // Kiểm tra đã đồng ý điều khoản
    if (!_acceptTerms) {
      showErrorDialog(t.termsRequired);
      return;
    }

    // Thêm trạng thái loading và xử lý đăng ký
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final response = await authService.register(fullName, email, password, MyApp.of(context)?.locale.languageCode ?? 'en');

      if(!mounted) return;
      
      if (response['success'] == true) {
        // Hiển thị thông báo thành công trước khi pop
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        
        // Đảm bảo Navigator.pop() chạy sau khi hiển thị SnackBar
        Future.delayed(Duration.zero, () {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(t.registerSuccess), 
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
            ),
          );
          
          Navigator.pop(context);
        });
      } 
      else {
        showErrorDialog(response['message'] ?? "Register failed");
      }
    } 
    catch (e) {
      if (mounted) showErrorDialog("Đăng ký thất bại: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF2C1D56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  FontAwesomeIcons.circleExclamation,
                  color: Colors.red,
                  size: 50,
                ),
                const SizedBox(height: 15),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9F43),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF281B30),
              Color(0xFF1D1340),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // AppBar với nút đổi ngôn ngữ và nút quay lại
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
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
                  itemBuilder: (BuildContext context) => [
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

            // Nội dung chính
            Expanded(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Image.asset('assets/logo.png', height: 100),

                      const SizedBox(height: 10),
                      Text(
                        t.createNewAccount,
                        style: const TextStyle(
                          fontSize: 26,
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

                      const SizedBox(height: 25),

                      // Card chứa form đăng ký
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
                            // Trường nhập họ tên
                            TextField(
                              controller: fullNameController,
                              focusNode: fullNameFocusNode,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.name,
                              onSubmitted:
                                  (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(emailFocusNode),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: t.fullName, 
                                prefixIcon: const Icon(
                                  FontAwesomeIcons.user,
                                  color: Colors.white70,
                                  size: 18,
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
                            const SizedBox(height: 15),

                            // Trường nhập email
                            TextField(
                              controller: emailController,
                              focusNode: emailFocusNode,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              onSubmitted:
                                  (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(passwordFocusNode),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: t.email,
                                prefixIcon: const Icon(
                                  FontAwesomeIcons.envelope,
                                  color: Colors.white70,
                                  size: 18,
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
                            const SizedBox(height: 15),

                            // Trường nhập mật khẩu
                            TextField(
                              controller: passwordController,
                              focusNode: passwordFocusNode,
                              textInputAction: TextInputAction.next,
                              obscureText: _obscurePassword,
                              onSubmitted:
                                  (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(confirmPasswordFocusNode),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: t.password,
                                prefixIcon: const Icon(
                                  FontAwesomeIcons.lock,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? FontAwesomeIcons.eyeSlash
                                        : FontAwesomeIcons.eye,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
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
                            const SizedBox(height: 15),

                            // Trường nhập xác nhận mật khẩu
                            TextField(
                              controller: confirmPasswordController,
                              focusNode: confirmPasswordFocusNode,
                              obscureText: _obscureConfirmPassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: t.confirmPassword, 
                                prefixIcon: const Icon(
                                  FontAwesomeIcons.lockOpen,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? FontAwesomeIcons.eyeSlash
                                        : FontAwesomeIcons.eye,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
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
                            const SizedBox(height: 10),

                            // Checkbox đồng ý điều khoản
                            Theme(
                              data: Theme.of(context).copyWith(
                                checkboxTheme: CheckboxThemeData(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _acceptTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _acceptTerms = value ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xFFFF9F43),
                                    checkColor: Colors.white,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _acceptTerms = !_acceptTerms;
                                        });
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          text: t.termsAgree,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: t.termsOfService,
                                              style: const TextStyle(
                                                color: Color(0xFFFF9F43),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Nút đăng ký
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
                                          t.register,
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

                      const SizedBox(height: 25),

                      // Nút chuyển sang Đăng nhập
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Đã có tài khoản? ", // Thay t.alreadyHaveAccount
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Quay lại màn hình đăng nhập
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              t.loginNow,
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
    );
  }
}