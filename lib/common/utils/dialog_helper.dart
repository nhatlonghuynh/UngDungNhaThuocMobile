import 'package:flutter/material.dart';
import 'package:nhathuoc_mobilee/common/constants/appcolor.dart';

class DialogHelper {
  // --- [MỚI THÊM] Hàm hỏi đăng nhập (Trả về True/False) ---
  static Future<bool?> showLoginRequirement(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Không cho bấm ra ngoài để đóng
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Chưa đăng nhập",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textBrown,
          ),
        ),
        content: const Text(
          "Vui lòng đăng nhập để xem thông tin hồ sơ cá nhân.",
        ),
        actions: [
          // Nút Thoát -> Trả về FALSE
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              "Để sau",
              style: TextStyle(color: AppColors.neutralGrey),
            ),
          ),
          // Nút Đăng nhập -> Trả về TRUE
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Đăng nhập"),
          ),
        ],
      ),
    );
  }

  // ... Giữ nguyên các hàm showError và showConfirmDialog cũ của bạn ở dưới ...
  static void showError(
    BuildContext context, {
    String title = "Thông báo",
    required String message,
  }) {
    // Code cũ của bạn...
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = "Hủy",
    String confirmText = "Đồng ý",
    Color? confirmColor,
  }) {
    // Code cũ của bạn...
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primaryPink,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static void showSuccessDialog(
    BuildContext context, {
    String title = "Thành công",
    required String message,
    VoidCallback? onPressed, // Hành động khi bấm OK (VD: Chuyển trang)
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // Icon check xanh lá
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop(); // Đóng Dialog trước
                if (onPressed != null) {
                  onPressed(); // Thực hiện hành động tiếp theo (nếu có)
                }
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
