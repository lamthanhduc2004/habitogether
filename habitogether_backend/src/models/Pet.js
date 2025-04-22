import mongoose from "mongoose";

const petSchema = new mongoose.Schema({
  name: { type: String, required: true },
  type: { 
    type: String, 
    required: true,
    enum: ['dragon', 'fox', 'axolotl']
  },
  level: { type: Number, required: true, default: 1 },
  experience: { type: Number, required: true, default: 0 },
  requiredExperience: { type: Number, required: true, default: 100 },
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true }
});

const Pet = mongoose.model("Pet", petSchema);
export default Pet;
