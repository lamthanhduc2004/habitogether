import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import '../models/daily_workout.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  WorkoutScreenState createState() => WorkoutScreenState();
}

class WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchWorkoutData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Lấy dữ liệu workout từ server
  Future<void> _fetchWorkoutData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );
      await workoutProvider.fetchWorkouts();
      await workoutProvider.fetchDailyWorkouts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Thêm workout vào danh sách hàng ngày
  Future<void> _addToDailyWorkout(Workout workout) async {
    try {
      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );
      final t = AppLocalizations.of(context);

      await workoutProvider.addToDailyWorkout(workout.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t?.workoutAdded ?? 'Đã thêm bài tập vào danh sách hôm nay',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Hoàn thành workout
  Future<void> _completeWorkout(DailyWorkout dailyWorkout) async {
    try {
      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );
      final t = AppLocalizations.of(context);

      final result = await workoutProvider.completeWorkout(dailyWorkout.id);

      if (mounted) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.levelUp
                  ? '${t?.levelUp ?? 'Lên cấp!'} ${t?.xpGained ?? 'Nhận được'} ${result.xpGained} XP!'
                  : '${t?.xpGained ?? 'Nhận được'} ${result.xpGained} XP!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Nếu lên cấp, hiển thị dialog chúc mừng
        if (result.levelUp) {
          _showLevelUpDialog(result.newLevel);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Hiển thị dialog chúc mừng khi lên cấp
  void _showLevelUpDialog(int newLevel) {
    final t = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: const Color(0xFF2C1D56),
            title: Text(
              t?.congrats ?? 'Chúc mừng!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
                const SizedBox(height: 16),
                Text(
                  '${t?.reachedLevel ?? 'Bạn đã đạt đến cấp độ'} $newLevel!',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  t?.ok ?? 'OK',
                  style: const TextStyle(
                    color: Color(0xFFFF9F43),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF281B30), Color(0xFF1D1340)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: null,
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              color: const Color(0xFF3A236A),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            padding: const EdgeInsets.symmetric(vertical: 8),
            tabs: [
              Tab(text: t?.todaysWorkouts ?? 'Kế hoạch hôm nay'),
              Tab(text: t?.allWorkouts ?? 'Mục tiêu của bạn'),
            ],
          ),
        ),
        body:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF9F43),
                    ),
                  ),
                )
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayPlanTab(workoutProvider, t),
                    _buildGoalsTab(workoutProvider, t),
                  ],
                ),
      ),
    );
  }

  // Tab Kế hoạch hôm nay
  Widget _buildTodayPlanTab(WorkoutProvider provider, AppLocalizations? t) {
    return RefreshIndicator(
      color: const Color(0xFFFF9F43),
      onRefresh: () => provider.fetchDailyWorkouts(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Phần tổng quan ngày
            _buildDailyOverview(provider),

            // Danh sách hoạt động
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hoạt động hôm nay',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.dailyWorkouts.isEmpty)
                    _buildEmptyState(
                      icon: FontAwesomeIcons.clipboardList,
                      title: 'Chưa có hoạt động nào cho hôm nay',
                      subtitle: 'Hãy thêm hoạt động từ danh sách mục tiêu nhé!',
                    )
                  else
                    ...provider.dailyWorkouts.map((dailyWorkout) {
                      return _buildActivityCard(dailyWorkout, t);
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị tổng quan ngày
  Widget _buildDailyOverview(WorkoutProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A236A), Color(0xFF4A337A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiến độ hôm nay',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F43),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.completedCount} bài tập',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value:
                  provider.completedCount /
                  (provider.completedCount + provider.dailyWorkouts.length),
              backgroundColor: Colors.white.withOpacity(0.3),
              color: const Color(0xFFFF9F43),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: FontAwesomeIcons.fire,
                value: '${provider.completedCount}',
                label: 'Đã hoàn thành',
                color: const Color(0xFFFF9F43),
              ),
              _buildStatItem(
                icon: FontAwesomeIcons.clock,
                value:
                    '${provider.dailyWorkouts.where((dw) => !dw.completed).length}',
                label: 'Còn lại',
                color: const Color(0xFF81C784),
              ),
              _buildStatItem(
                icon: FontAwesomeIcons.star,
                value:
                    '${provider.dailyWorkouts.fold(0, (sum, item) => sum + item.workout.xpReward)}',
                label: 'XP có thể nhận',
                color: const Color(0xFFFFD54F),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12, color: Colors.white.withOpacity(0.7)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Tab Mục tiêu của bạn
  Widget _buildGoalsTab(WorkoutProvider provider, AppLocalizations? t) {
    return RefreshIndicator(
      color: const Color(0xFFFF9F43),
      onRefresh: () => provider.fetchWorkouts(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần tổng quan mục tiêu
              _buildGoalsOverview(provider),
              const SizedBox(height: 24),

              // Danh mục mục tiêu
              const Text(
                'Danh mục mục tiêu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Mục tiêu sức khỏe
              _buildGoalCategory(
                title: 'Sức khỏe & Thể chất',
                icon: FontAwesomeIcons.dumbbell,
                color: const Color(0xFF81C784),
                workouts:
                    provider.workouts
                        .where((w) => w.difficulty == 'easy')
                        .toList(),
                t: t,
              ),
              const SizedBox(height: 16),

              // Mục tiêu trung bình
              _buildGoalCategory(
                title: 'Rèn luyện & Phát triển',
                icon: FontAwesomeIcons.brain,
                color: const Color(0xFF64B5F6),
                workouts:
                    provider.workouts
                        .where((w) => w.difficulty == 'medium')
                        .toList(),
                t: t,
              ),
              const SizedBox(height: 16),

              // Mục tiêu học tập
              _buildGoalCategory(
                title: 'Học tập & Phát triển',
                icon: FontAwesomeIcons.book,
                color: const Color(0xFFFF9F43),
                workouts:
                    provider.workouts
                        .where((w) => w.difficulty == 'hard')
                        .toList(),
                t: t,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsOverview(WorkoutProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A236A), Color(0xFF4A337A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan mục tiêu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGoalStat(
                icon: FontAwesomeIcons.flag,
                value: '${provider.workouts.length}',
                label: 'Mục tiêu',
                color: const Color(0xFFFF9F43),
              ),
              _buildGoalStat(
                icon: FontAwesomeIcons.check,
                value: '${provider.completedCount}',
                label: 'Đã đạt được',
                color: const Color(0xFF81C784),
              ),
              _buildGoalStat(
                icon: FontAwesomeIcons.star,
                value:
                    '${provider.workouts.fold(0, (sum, item) => sum + item.xpReward)}',
                label: 'Tổng XP',
                color: const Color(0xFFFFD54F),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoalCategory({
    required String title,
    required IconData icon,
    required Color color,
    required List<Workout> workouts,
    required AppLocalizations? t,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (workouts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Chưa có mục tiêu nào',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...workouts.map((workout) => _buildGoalItem(workout, t)),
        ],
      ),
    );
  }

  Widget _buildGoalItem(Workout workout, AppLocalizations? t) {
    final isAlreadyAdded = Provider.of<WorkoutProvider>(
      context,
    ).dailyWorkouts.any((dw) => dw.workout.id == workout.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          workout.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: isAlreadyAdded ? null : () => _addToDailyWorkout(workout),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9F43),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          child: Text(
            isAlreadyAdded ? 'Đã thêm' : 'Thêm',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(DailyWorkout dailyWorkout, AppLocalizations? t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            dailyWorkout.workout.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                dailyWorkout.workout.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFD54F),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.star,
                          color: Color(0xFFFFD54F),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+${dailyWorkout.workout.xpReward} XP',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            margin: const EdgeInsets.only(left: 10),
            child: ElevatedButton(
              onPressed: () => _completeWorkout(dailyWorkout),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F43),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Hoàn thành',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(icon, size: 60, color: const Color(0xFFFF9F43)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
