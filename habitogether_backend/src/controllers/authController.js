import bcrypt from "bcryptjs";
import User from "../models/User.js";

// Xử lý đăng nhập
export const loginUser = async (req, res) => {
  const messages = {
    en: {
      user_not_found: "User does not exist!",
      incorrect_password: "Password is incorrect!"
    },
    vi: {
      user_not_found: "Người dùng không tồn tại!",
      incorrect_password: "Mật khẩu không chính xác!"
    }
  };

  const { email, password, lang } = req.body;

   try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: messages[lang]?.user_not_found || "User not found!"
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: messages[lang]?.incorrect_password || "Incorrect password!"
      });
    }

    res.status(200).json({
      success: true,
      id: user._id,
      fullName: user.fullName,
      email: user.email,
      avatar: user.avatar
    });

  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
};