import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import '../providers/user_provider.dart';
import 'dart:convert';

// Cache để lưu kết quả kiểm tra tồn tại của file
final Map<String, PetAnimationType> _assetTypeCache = {};
// Cache lưu trữ hình ảnh đã tải
final Map<String, Image> _imageCache = {};
// Cache lưu trữ ImageProvider để duy trì tham chiếu liên tục
final Map<String, ImageProvider> _imageProviders = {};
// Cache cho AnimationController để GIF không bị restart khi rebuild
final Map<String, AnimationController> _gifControllers = {};

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final Map<String, AnimationController> _petAnimationControllers = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Tải trước các hình ảnh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Pre-cache lại GIF của thú cưng hiện tại mỗi khi dependencies thay đổi
    if (mounted && context.read<PetProvider>().activePet != null) {
      final pet = context.read<PetProvider>().activePet!;
      if (!_imageProviders.containsKey(pet.gifAsset)) {
        _imageProviders[pet.gifAsset] = AssetImage(pet.gifAsset);
      }
      precacheImage(_imageProviders[pet.gifAsset]!, context);
      
      // Tạo controller cho GIF của pet hiện tại nếu chưa có
      final gifPath = pet.gifAsset;
      if (!_petAnimationControllers.containsKey(gifPath)) {
        _petAnimationControllers[gifPath] = AnimationController(
          vsync: this,
          duration: const Duration(
            milliseconds: 1000,
          ), // Điều chỉnh tốc độ animation
        )..repeat();
      }
    }
  }

  // Tải trước các hình ảnh
  Future<void> _preloadImages(BuildContext context) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    for (var pet in petProvider.pets) {
      for (int level = 0; level <= 5; level++) {
        final assetPath =
            'assets/pets/${pet.type.name.toLowerCase()}/evolution_$level.gif';
        try {
          // Tạo và lưu trữ ImageProvider
          if (!_imageProviders.containsKey(assetPath)) {
            _imageProviders[assetPath] = AssetImage(assetPath);
          }

          // Buộc tải trước
          await precacheImage(_imageProviders[assetPath]!, context);

          // Tạo và lưu trữ Image widget cũng để dùng sau này
          final image = Image(
            image: _imageProviders[assetPath]!,
            gaplessPlayback: true,
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
            width: 200,
            height: 200,
          );

          // Lưu trữ Image widget vào cache
          _imageCache[assetPath] = image;
          
          // Tạo controller cho animation
          if (!_petAnimationControllers.containsKey(assetPath)) {
            _petAnimationControllers[assetPath] = AnimationController(
              vsync: this,
              duration: const Duration(
                milliseconds: 1000,
              ), // Điều chỉnh tốc độ animation
            )..repeat();
          }
        } catch (e) {
          // Bỏ qua lỗi
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    
    // Giải phóng tất cả controller
    for (var controller in _petAnimationControllers.values) {
      controller.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        // Hiển thị loading indicator nếu đang tải
        if (petProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Hiển thị thông báo lỗi nếu có
        if (petProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  petProvider.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Thử tải lại dữ liệu
                    petProvider.loadPets('user_id'); // Thay thế 'user_id' bằng ID thực tế
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final pet = petProvider.activePet;

        if (pet == null) {
          return const Center(child: Text('Không có thú cưng nào được chọn'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Tên thú cưng và loại
              Text(
                '${pet.name} - ${pet.type.displayName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // Hiển thị cấp độ
              Text(
                'Cấp độ: ${pet.level} (Tiến hóa: ${pet.evolutionStage}/${pet.maxEvolutionStage})',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 30),

              // Hiển thị thú cưng dạng animation
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Center(child: _buildPetAnimation(pet)),
                ),
              ),

              // Thêm nút tăng kinh nghiệm
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.fitness_center),
                label: const Text('Tập luyện (+50 EXP)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  _trainPet(context);
                },
              ),
              const SizedBox(height: 10),

              // Hiển thị thanh kinh nghiệm
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kinh nghiệm: ${pet.experience}/${50 * pet.level * pet.evolutionStage}',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: pet.experience / (50 * pet.level * pet.evolutionStage),
                      minHeight: 20,
                      backgroundColor: Colors.blueGrey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pet.getEvolutionColor(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Nút chọn thú cưng
              ElevatedButton.icon(
                icon: const Icon(Icons.pets),
                label: const Text('Đổi thú cưng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  // Kiểm tra xem pet hiện tại đã đạt cấp độ cao nhất chưa
                  if (pet.evolutionStage < pet.maxEvolutionStage) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Không thể đổi thú cưng'),
                        content: Text(
                          'Bạn cần đạt đến cấp độ cao nhất (${pet.maxEvolutionStage}) của ${pet.name} để đổi thú cưng',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  _showPetSelectionDialog(context, petProvider);
                },
              ),

              // Nút debug
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.bug_report),
                label: const Text('Debug Assets'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                ),
                onPressed: () {
                  _debugAssets(context, petProvider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget để hiển thị animation cho thú cưng
  Widget _buildPetAnimation(Pet pet) {
    // Kiểm tra xem đã có kết quả trong cache chưa
    final cacheKey = pet.gifAsset;
    final cachedResult = _assetTypeCache[cacheKey];

    if (cachedResult != null) {
      // Nếu đã có trong cache, hiển thị ngay lập tức
      return _buildAnimationWidgetByType(pet, cachedResult);
    }

    return FutureBuilder(
      future: _checkFileExists(pet),
      builder: (context, AsyncSnapshot<PetAnimationType> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Hiển thị spinner khi đang kiểm tra các file
          return const CircularProgressIndicator();
        }

        final animationType = snapshot.data ?? PetAnimationType.none;

        // Lưu kết quả vào cache
        _assetTypeCache[cacheKey] = animationType;

        return _buildAnimationWidgetByType(pet, animationType);
      },
    );
  }

  // Hàm helper để xây dựng widget hiển thị dựa trên loại animation
  Widget _buildAnimationWidgetByType(Pet pet, PetAnimationType type) {
    switch (type) {
      case PetAnimationType.lottie:
        return _buildLottieAnimation(pet);
      case PetAnimationType.gif:
        // Chọn phương pháp phù hợp tùy theo nền tảng
        if (kIsWeb) {
          // Web hiển thị GIF tốt, dùng phương pháp đơn giản
          return _buildWebGifAnimation(pet);
        } else {
          // Android cần phương pháp tối ưu hơn
          return _buildOptimizedGifAnimation(pet);
        }
      case PetAnimationType.image:
        return _buildStaticImage(pet);
      case PetAnimationType.none:
        return _buildFallbackIcon(pet);
    }
  }

  // Hiển thị Lottie animation
  Widget _buildLottieAnimation(Pet pet) {
    return Lottie.asset(
      pet.lottieAsset,
      width: pet.getEvolutionSize() * 1.5,
      height: pet.getEvolutionSize() * 1.5,
      fit: BoxFit.contain,
      controller: _animationController,
      onLoaded: (composition) {
        _animationController
          ..duration = composition.duration
          ..repeat();
      },
    );
  }
  
  // Animation GIF đơn giản cho Web
  Widget _buildWebGifAnimation(Pet pet) {
    final gifPath = pet.gifAsset;
    
    return RepaintBoundary(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Transform.scale(
          scale: 2.0, // Phóng to gấp đôi kích thước gốc
          child: Image.asset(
            gifPath,
            gaplessPlayback: true,
            isAntiAlias: true,
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // Animation GIF tối ưu cho Android
  Widget _buildOptimizedGifAnimation(Pet pet) {
    final gifPath = pet.gifAsset;

    // Lấy hoặc tạo mới controller nếu chưa có
    if (!_petAnimationControllers.containsKey(gifPath)) {
      _petAnimationControllers[gifPath] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      )..repeat();
    }

    final controller = _petAnimationControllers[gifPath]!;
    if (!controller.isAnimating) {
      controller.repeat();
    }

    return RepaintBoundary(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.8, // Giảm từ 2.0 xuống 1.8 để tránh vấn đề hiệu suất
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              // Sử dụng animated opacity để mô phỏng hiệu ứng pulse thay vì GIF
              return AnimatedOpacity(
                opacity: 0.9 + 0.1 * controller.value,
                duration: const Duration(milliseconds: 200),
                child: Image.asset(
                  gifPath,
                  gaplessPlayback: true,
                  isAntiAlias: true,
                  filterQuality:
                      FilterQuality
                          .medium, // Giảm xuống medium để tăng hiệu suất
                  fit: BoxFit.contain,
                  cacheWidth: 250, // Tối ưu bộ nhớ cache
                  cacheHeight: 250, // Tối ưu bộ nhớ cache
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackIcon(pet);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Hiển thị hình ảnh tĩnh
  Widget _buildStaticImage(Pet pet) {
    return Image.asset(
      pet.imageAsset,
      width: pet.getEvolutionSize() * 1.5,
      height: pet.getEvolutionSize() * 1.5,
      fit: BoxFit.contain,
    );
  }

  // Hiển thị icon fallback
  Widget _buildFallbackIcon(Pet pet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          pet.getEvolutionIcon(),
          size: pet.getEvolutionSize(),
          color: pet.getEvolutionColor(),
        ),
        const SizedBox(height: 20),
        Text(
          '${pet.type.displayName} - Tiến hóa ${pet.evolutionStage}',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Vui lòng kiểm tra đường dẫn file trong assets',
          style: TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Kiểm tra xem file animation nào tồn tại
  Future<PetAnimationType> _checkFileExists(Pet pet) async {
    final lottieAsset = pet.lottieAsset;
    final gifAsset = pet.gifAsset;
    final imageAsset = pet.imageAsset;
    final buildContext = context;

    // Trực tiếp ưu tiên sử dụng GIF nếu trước đó đã tìm thấy
    try {
      await DefaultAssetBundle.of(buildContext).load(gifAsset);
      return PetAnimationType.gif;
    } catch (e) {
      try {
        await DefaultAssetBundle.of(buildContext).load(imageAsset);
        return PetAnimationType.image;
      } catch (e) {
        try {
          await DefaultAssetBundle.of(buildContext).load(lottieAsset);
          return PetAnimationType.lottie;
        } catch (e) {
          return PetAnimationType.none;
        }
      }
    }
  }

  // Hiển thị dialog chọn thú cưng
  void _showPetSelectionDialog(BuildContext context, PetProvider petProvider) {
    final userId = context.read<UserProvider>().id;
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn thú cưng'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: petProvider.pets.length,
            itemBuilder: (context, index) {
              final pet = petProvider.pets[index];
              return ListTile(
                leading: Icon(
                  getPetIcon(pet.type),
                  color: getPetColor(pet.type),
                ),
                title: Text(pet.name),
                subtitle: Text(
                  '${pet.type.displayName} - Cấp ${pet.level}',
                ),
                onTap: () {
                  petProvider.setActivePet(userId, pet.id);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Lấy icon tương ứng cho loại thú cưng
  IconData getPetIcon(PetType type) {
    switch (type) {
      case PetType.dragon:
        return Pet.getIconForDragonLevel(0);
      case PetType.fox:
        return Pet.getIconForFoxLevel(0);
      case PetType.axolotl:
        return Pet.getIconForAxolotlLevel(0);
    }
  }

  // Lấy màu tương ứng cho loại thú cưng
  Color getPetColor(PetType type) {
    switch (type) {
      case PetType.dragon:
        return Colors.red;
      case PetType.fox:
        return Colors.orange;
      case PetType.axolotl:
        return Colors.pink;
    }
  }

  // Debug hiển thị thông tin về các file assets
  void _debugAssets(BuildContext context, PetProvider petProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Debug Asset Paths'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin thú cưng:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Tên: ${petProvider.activePet?.name}'),
                  Text('Loại: ${petProvider.activePet?.type.displayName}'),
                  Text('Level: ${petProvider.activePet?.level}'),
                  Text(
                    'Evolution Stage: ${petProvider.activePet?.evolutionStage}',
                  ),
                  const Divider(),

                  Text(
                    'Đường dẫn Asset:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('GIF: ${petProvider.activePet?.gifAsset}'),
                  Text('Lottie: ${petProvider.activePet?.lottieAsset}'),
                  Text('PNG: ${petProvider.activePet?.imageAsset}'),
                  Text('Platform: ${kIsWeb ? "Web" : "Mobile"}'),
                  const Divider(),

                  Text(
                    'Cấu trúc file:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder(
                    future: DefaultAssetBundle.of(
                      context,
                    ).loadString('AssetManifest.json'),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      if (!mounted) {
                        return const Text('Widget không còn được gắn kết');
                      }
                      try {
                        final Map<String, dynamic> manifestMap =
                            Map<String, dynamic>.from(
                              json.decode(snapshot.data.toString()),
                            );

                        final petAssets =
                            manifestMap.keys
                                .where((String key) => key.contains('pets'))
                                .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tìm thấy ${petAssets.length} file:'),
                            ...petAssets.map((asset) => Text('- $asset')),
                          ],
                        );
                      } catch (e) {
                        return Text('Lỗi: $e');
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  // Nút tập luyện để tăng kinh nghiệm cho pet
  void _trainPet(BuildContext context) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final pet = petProvider.activePet;
    final userId = userProvider.id;

    if (pet == null || userId == null) return;

    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Tăng kinh nghiệm cho pet
      await petProvider.gainExperience(userId, pet.id, 50);

      // Đóng dialog loading
      if (mounted) Navigator.of(context).pop();

      // Hiển thị thông báo thành công
      if (mounted) {
        final snackBar = SnackBar(
          content: Text('${pet.name} đã nhận được 50 điểm kinh nghiệm!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      // Đóng dialog loading nếu có lỗi
      if (mounted) Navigator.of(context).pop();

      // Hiển thị thông báo lỗi
      if (mounted) {
        final snackBar = SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}

// Enum cho các loại animation thú cưng
enum PetAnimationType {
  lottie, // Lottie JSON animation
  gif, // GIF animation
  image, // Hình ảnh tĩnh
  none, // Không có animation, sử dụng icon
}
