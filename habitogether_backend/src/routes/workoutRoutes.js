// import express from 'express';
// import { 
//   getAllWorkouts, 
//   createWorkout, 
//   getDailyWorkouts, 
//   addToDailyWorkout, 
//   completeWorkout 
// } from '../controllers/workoutController.js';
// import { authenticateUser } from '../middleware/auth.js';

// const router = express.Router();

// // Lấy danh sách tất cả workout
// router.get('/workouts', authenticateUser, getAllWorkouts);

// // Tạo workout mới
// router.post('/workouts', authenticateUser, createWorkout);

// // Lấy danh sách daily workout của user
// router.get('/daily-workouts', authenticateUser, getDailyWorkouts);

// // Thêm workout vào danh sách hôm nay
// router.post('/daily-workouts', authenticateUser, addToDailyWorkout);

// // Hoàn thành workout và nhận XP
// router.post('/complete-workout', authenticateUser, completeWorkout);

// export default router; 