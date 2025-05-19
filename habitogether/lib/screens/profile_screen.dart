import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/user_provider.dart';
import '../providers/pet_provider.dart';
import '../models/pet.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _petAnimationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _petAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController.forward();
    _petAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _petAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);

    final activePet = petProvider.activePet;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Hồ sơ của tôi',
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
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Profile Header - Hiệu ứng Slide Down và Fade In
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          (1 - _animationController.value) * -30,
                        ),
                        child: Opacity(
                          opacity: _animationController.value,
                          child: child,
                        ),
                      );
                    },
                    child: _buildProfileHeader(userProvider),
                  ),

                  const SizedBox(height: 24),

                  // Stats Cards - Hiệu ứng Fade In
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _animationController.value,
                        child: child,
                      );
                    },
                    child: _buildStatsSection(),
                  ),

                  const SizedBox(height: 24),

                  // Current Pet Section - Hiệu ứng Slide Up
                  if (activePet != null)
                    AnimatedBuilder(
                      animation: _petAnimationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            (1 - _petAnimationController.value) * 50,
                          ),
                          child: Opacity(
                            opacity: _petAnimationController.value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildActivePetCard(activePet),
                    ),

                  const SizedBox(height: 24),

                  // Action Buttons - Hiệu ứng Fade In trễ
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Bắt đầu hiển thị khi animation chính đạt 60%
                      final delayedValue =
                          (_animationController.value - 0.6).clamp(0.0, 0.4) *
                          2.5;
                      return Opacity(opacity: delayedValue, child: child);
                    },
                    child: _buildActionButtons(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // SECTION 1: Profile Header với Avatar và Thông tin người dùng
  Widget _buildProfileHeader(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A236A), Color(0xFF4A337A), Color(0xFF3A236A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar với border gradient
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9F43), Color(0xFFFF7043)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9F43).withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

              // Avatar image
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.black45,
                child:
                    userProvider.avatar != null &&
                            userProvider.avatar!.isNotEmpty
                        ? ClipOval(
                          child: Image.network(
                            userProvider.avatar!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  FontAwesomeIcons.user,
                                  size: 60,
                                  color: Colors.white,
                                ),
                          ),
                        )
                        : const Icon(
                          FontAwesomeIcons.user,
                          size: 60,
                          color: Colors.white,
                        ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // User name with shadow
          Text(
            userProvider.fullName ?? 'Người dùng',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  offset: Offset(0, 2),
                  blurRadius: 5,
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // Email
          Text(
            userProvider.email ?? 'email@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 20),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9F43), Color(0xFFFF7043)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9F43).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  FontAwesomeIcons.crown,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Cấp độ 5',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SECTION 2: Stats Section với hiệu ứng glassmorphism
  Widget _buildStatsSection() {
    final petProvider = Provider.of<PetProvider>(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Bài tập đã hoàn thành",
            "56",
            FontAwesomeIcons.dumbbell,
            const Color(0xFF81C784),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            "Thú cưng",
            "${petProvider.pets.length}",
            FontAwesomeIcons.paw,
            const Color(0xFFFF9F43),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // SECTION 3: Active Pet Card với hiệu ứng
  Widget _buildActivePetCard(Pet activePet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A236A), Color(0xFF4A337A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FontAwesomeIcons.paw,
                  color: Color(0xFFFF9F43),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Thú cưng hiện tại',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pet image
              Hero(
                tag: 'pet-${activePet.id}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      activePet.gifAsset,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                            activePet.getEvolutionIcon(),
                            size: 40,
                            color: activePet.getEvolutionColor(),
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Pet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activePet.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Cấp ${activePet.level}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9F43),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activePet.type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // XP Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 12,
                          child: Stack(
                            children: [
                              // Background
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),

                              // Progress
                              FractionallySizedBox(
                                widthFactor:
                                    activePet.experience /
                                    (50 *
                                        activePet.level *
                                        activePet.evolutionStage),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF9F43),
                                        Color(0xFFFF7043),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFFF9F43,
                                        ).withOpacity(0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'XP: ${activePet.experience}/${50 * activePet.level * activePet.evolutionStage}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SECTION 4: Action Buttons với hiệu ứng hover
  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          title: 'Chỉnh sửa hồ sơ',
          icon: FontAwesomeIcons.userPen,
          onTap: () {
            // Xử lý khi nhấp vào nút
          },
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          title: 'Lịch sử hoạt động',
          icon: FontAwesomeIcons.clockRotateLeft,
          onTap: () {
            // Xử lý khi nhấp vào nút
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
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
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
