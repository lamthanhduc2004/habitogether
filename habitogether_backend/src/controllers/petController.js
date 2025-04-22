import User from "../models/User.js";
import Pet from "../models/Pet.js";

// Lấy danh sách pet của user
export const getUserPets = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId).populate('pets');
    
    if (!user) {
      return res.status(404).json({ message: "Không tìm thấy người dùng" });
    }

    res.status(200).json(user.pets || []);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server" });
  }
};

// Lấy pet hiện tại của user
export const getCurrentPet = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId).populate('currentPet');
    
    if (!user) {
      return res.status(404).json({ message: "Không tìm thấy người dùng" });
    }

    res.status(200).json(user.currentPet);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server" });
  }
};

// Cập nhật pet hiện tại của user
export const setCurrentPet = async (req, res) => {
  try {
    const { userId } = req.params;
    const { petId } = req.body;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "Không tìm thấy người dùng" });
    }

    const pet = await Pet.findById(petId);
    if (!pet) {
      return res.status(404).json({ message: "Không tìm thấy pet" });
    }

    user.currentPet = petId;
    await user.save();

    res.status(200).json({ message: "Cập nhật pet hiện tại thành công" });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server" });
  }
};

// Thêm kinh nghiệm cho pet
export const addExperience = async (req, res) => {
  try {
    const { petId } = req.params;
    const { amount } = req.body;

    const pet = await Pet.findById(petId);
    if (!pet) {
      return res.status(404).json({ message: "Không tìm thấy pet" });
    }

    pet.experience += amount;
    
    // Kiểm tra level up
    let requiredExperience = 50; // Kinh nghiệm cần thiết ban đầu
    while (pet.experience >= requiredExperience) {
      pet.experience -= requiredExperience;
      pet.level += 1;
      requiredExperience += 50; // Tăng thêm 50 cho mỗi cấp độ
    }

    await pet.save();
    res.status(200).json(pet);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server" });
  }
};

// Đổi tên pet
export const renamePet = async (req, res) => {
  try {
    const { petId } = req.params;
    const { name } = req.body;

    const pet = await Pet.findById(petId);
    if (!pet) {
      return res.status(404).json({ message: "Không tìm thấy pet" });
    }

    pet.name = name;
    await pet.save();

    res.status(200).json(pet);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server" });
  }
}; 