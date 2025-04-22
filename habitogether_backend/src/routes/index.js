import express from "express";
import authRoutes from "./authRoutes.js";
import registerRoutes from "./registerRoutes.js";
import petRoutes from "./petRoutes.js";
// import workoutRoutes from "./workoutRoutes.js";

const router = express.Router();

router.use("/login", authRoutes);
router.use("/register", registerRoutes);
router.use("/", petRoutes);
// router.use("/", workoutRoutes);

export default router;
