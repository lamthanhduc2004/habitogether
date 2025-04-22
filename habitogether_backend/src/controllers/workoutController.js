import Workout from '../models/workout.js';
import DailyWorkout from '../models/dailyWorkout.js';
import User from '../models/user.js';
import mongoose from 'mongoose';

// Lấy danh sách tất cả workout
export const getAllWorkouts = async (req, res) => {
  try {
    const workouts = await Workout.find({}).sort({ difficulty: 1, name: 1 });
    res.status(200).json({ success: true, data: workouts });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Tạo workout mới
export const createWorkout = async (req, res) => {
  try {
    const { name, difficulty, description } = req.body;
    
    if (!name || !difficulty || !description) {
      return res.status(400).json({ success: false, message: 'Vui lòng điền đầy đủ thông tin' });
    }
    
    const newWorkout = new Workout({
      name,
      difficulty,
      description
    });
    
    await newWorkout.save();
    res.status(201).json({ success: true, data: newWorkout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Lấy danh sách daily workout của user
export const getDailyWorkouts = async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Lấy ngày hôm nay (reset về 00:00:00)
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    // Lấy danh sách daily workout chưa hoàn thành của user
    const dailyWorkouts = await DailyWorkout.find({
      userId,
      date: { $gte: today, $lt: tomorrow },
      completed: false
    }).populate('workout');
    
    // Đếm số workout đã hoàn thành hôm nay
    const completedCount = await DailyWorkout.countDocuments({
      userId,
      date: { $gte: today, $lt: tomorrow },
      completed: true
    });
    
    res.status(200).json({ 
      success: true, 
      data: { 
        dailyWorkouts,
        completedCount,
        maxDaily: 5 // Số lượng tối đa workout có thể hoàn thành trong ngày
      } 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Thêm workout vào danh sách hôm nay
export const addToDailyWorkout = async (req, res) => {
  try {
    const userId = req.user.id;
    const { workoutId } = req.body;
    
    if (!workoutId) {
      return res.status(400).json({ success: false, message: 'Thiếu thông tin workout' });
    }
    
    // Kiểm tra xem workout có tồn tại không
    const workout = await Workout.findById(workoutId);
    if (!workout) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy bài tập' });
    }
    
    // Lấy ngày hôm nay (reset về 00:00:00)
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    // Kiểm tra xem user đã có workout này trong danh sách hôm nay chưa
    const existingWorkout = await DailyWorkout.findOne({
      userId,
      workout: workoutId,
      date: { $gte: today, $lt: tomorrow }
    });
    
    if (existingWorkout) {
      return res.status(400).json({ success: false, message: 'Bài tập này đã có trong danh sách hôm nay' });
    }
    
    // Kiểm tra xem user đã đạt giới hạn số lượng workout hàng ngày chưa
    const dailyCount = await DailyWorkout.countDocuments({
      userId,
      date: { $gte: today, $lt: tomorrow }
    });
    
    if (dailyCount >= 5) {
      return res.status(400).json({ success: false, message: 'Bạn đã đạt giới hạn số lượng bài tập hàng ngày' });
    }
    
    // Tạo daily workout mới
    const newDailyWorkout = new DailyWorkout({
      userId,
      workout: workoutId,
      date: today
    });
    
    await newDailyWorkout.save();
    
    // Trả về daily workout với thông tin workout
    const populatedDailyWorkout = await DailyWorkout.findById(newDailyWorkout._id).populate('workout');
    
    res.status(201).json({ success: true, data: populatedDailyWorkout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Hoàn thành workout và nhận XP
export const completeWorkout = async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  
  try {
    const userId = req.user.id;
    const { dailyWorkoutId } = req.body;
    
    if (!dailyWorkoutId) {
      return res.status(400).json({ success: false, message: 'Thiếu thông tin bài tập' });
    }
    
    // Kiểm tra xem daily workout có tồn tại không
    const dailyWorkout = await DailyWorkout.findOne({ 
      _id: dailyWorkoutId,
      userId
    }).populate('workout').session(session);
    
    if (!dailyWorkout) {
      await session.abortTransaction();
      session.endSession();
      return res.status(404).json({ success: false, message: 'Không tìm thấy bài tập' });
    }
    
    if (dailyWorkout.completed) {
      await session.abortTransaction();
      session.endSession();
      return res.status(400).json({ success: false, message: 'Bài tập này đã được hoàn thành' });
    }
    
    // Cập nhật trạng thái completed
    dailyWorkout.completed = true;
    await dailyWorkout.save({ session });
    
    // Cộng XP cho user
    const xpReward = dailyWorkout.workout.xpReward;
    const user = await User.findById(userId).session(session);
    
    user.xp += xpReward;
    
    // Kiểm tra nâng cấp level nếu cần
    const newLevel = Math.floor(user.xp / 100) + 1; // Mỗi 100 XP sẽ lên 1 level
    if (newLevel > user.level) {
      user.level = newLevel;
    }
    
    await user.save({ session });
    
    await session.commitTransaction();
    session.endSession();
    
    res.status(200).json({ 
      success: true, 
      data: { 
        xpGained: xpReward,
        newXP: user.xp,
        newLevel: user.level,
        levelUp: newLevel > user.level - 1
      } 
    });
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    res.status(500).json({ success: false, message: error.message });
  }
}; 