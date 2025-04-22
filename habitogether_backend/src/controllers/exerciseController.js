import Exercise from '../models/Exercise.js';

// Lấy danh sách bài tập
export const getExercises = async (req, res) => {
  try {
    const exercises = await Exercise.find({ userId: req.user._id });
    res.json(exercises);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Lấy danh sách bài tập đã hoàn thành trong ngày
export const getCompletedExercises = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const exercises = await Exercise.find({
      userId: req.user._id,
      isCompleted: true,
      completedAt: { $gte: today }
    });
    
    res.json(exercises);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Hoàn thành bài tập
export const completeExercise = async (req, res) => {
  try {
    const exercise = await Exercise.findOne({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!exercise) {
      return res.status(404).json({ message: 'Không tìm thấy bài tập' });
    }

    // Kiểm tra số lượng bài tập đã hoàn thành trong ngày
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const completedCount = await Exercise.countDocuments({
      userId: req.user._id,
      isCompleted: true,
      completedAt: { $gte: today }
    });

    if (completedCount >= 5) {
      return res.status(400).json({ message: 'Đã đạt giới hạn 5 bài tập mỗi ngày' });
    }

    exercise.isCompleted = true;
    exercise.completedAt = new Date();
    await exercise.save();

    res.json(exercise);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Reset trạng thái bài tập hàng ngày
export const resetDailyExercises = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    await Exercise.updateMany(
      {
        userId: req.user._id,
        completedAt: { $lt: today }
      },
      {
        $set: {
          isCompleted: false,
          completedAt: null
        }
      }
    );

    res.json({ message: 'Đã reset trạng thái bài tập' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}; 