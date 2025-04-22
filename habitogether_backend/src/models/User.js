import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  avatar: { type: String, default: "" },
  createdAt: { type: Date, default: Date.now },
  xp: { type: Number, default: 0 },
  level: { type: Number, default: 1 },

  // Pet hiện tại của user (chỉ có 1 pet tại một thời điểm)
  currentPet: { type: mongoose.Schema.Types.ObjectId, ref: "Pet", default: null },
  
  // Danh sách tất cả pet của user
  pets: [{ type: mongoose.Schema.Types.ObjectId, ref: "Pet" }]
});

const User = mongoose.model("User", userSchema);
export default User;
