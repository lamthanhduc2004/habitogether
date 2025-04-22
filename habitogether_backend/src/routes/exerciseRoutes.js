// import express from 'express';
// import { authenticateToken } from '../middleware/auth.js';
// import {
//   getExercises,
//   getCompletedExercises,
//   completeExercise,
//   resetDailyExercises
// } from '../controllers/exerciseController.js';

// const router = express.Router();

// // Tất cả các routes đều yêu cầu xác thực
// router.use(authenticateToken);

// // Lấy danh sách bài tập
// router.get('/', getExercises);

// // Lấy danh sách bài tập đã hoàn thành trong ngày
// router.get('/completed', getCompletedExercises);

// // Hoàn thành bài tập
// router.post('/:id/complete', completeExercise);

// // Reset trạng thái bài tập hàng ngày
// router.post('/reset', resetDailyExercises);

// export default router; 