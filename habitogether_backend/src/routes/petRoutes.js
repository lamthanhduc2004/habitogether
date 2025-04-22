import express from "express";
import { getUserPets, getCurrentPet, setCurrentPet, addExperience, renamePet } from "../controllers/petController.js";

const router = express.Router();

// Lấy danh sách pet của user
router.get("/users/:userId/pets", getUserPets);

// Lấy pet hiện tại của user
router.get("/users/:userId/current-pet", getCurrentPet);

// Cập nhật pet hiện tại của user
router.put("/users/:userId/current-pet", setCurrentPet);

// Thêm kinh nghiệm cho pet
router.post("/pets/:petId/experience", addExperience);

// Đổi tên pet
router.put("/pets/:petId/name", renamePet);

export default router; 