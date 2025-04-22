import bcrypt from "bcryptjs";
import User from "../models/User.js";

// Xử lý đăng ký
export const registerUser = async (req, res) => {

    const messages = {
        en: {
          exist_email: "Email is existed!",
        },
        vi: {
          exist_email: "Email đã tồn tại!",
        }
    };

    try {
        const { fullName, email, password, lang } = req.body;

        // Kiểm tra xem email đã tồn tại chưa
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: messages[lang]?.exist_email || "Email is existed!",
            });
        }

        // Mã hóa mật khẩu
        const hashedPassword = await bcrypt.hash(password, 10);

        // Tạo user mới
        const newUser = new User({
            fullName,
            email,
            password: hashedPassword,
        });

        await newUser.save();

        res.status(201).json({
            success: true,
            message: "Đăng ký thành công!",
            user: {
                fullName: newUser.fullName,
                email: newUser.email,
            },
        });

    } catch (error) {
        console.error("Lỗi đăng ký:", error);
        res.status(500).json({
            success: false,
            message: "Đã xảy ra lỗi trong quá trình đăng ký.",
        });
    }
};
