# Andrewix - NixOS & Home Manager Configuration

## 🚀 Cách sử dụng nhanh

Để áp dụng cấu hình mới nhất:

```bash
nh os switch ~/dotconfigs
```

Để cập nhật tất cả các thư viện (inputs):

```bash
nix flake update --flake ~/dotconfigs
```

## 🛠 Cấu trúc thư mục

- `modules/system/features/`: Chứa các module cấu hình cấp hệ thống (NixOS). Mọi file `.nix` thêm vào đây sẽ được tự động import.
- `modules/user/features/`: Chứa các module cấu hình cấp người dùng (Home Manager). Mọi file `.nix` thêm vào đây sẽ được tự động import.
- `modules/hosts/`: Cấu hình riêng cho từng thiết bị (Phần cứng, hostname).
- `flake.nix`: Điểm bắt đầu của toàn bộ cấu hình.

## 📝 Cách chỉnh sửa & Thêm mới

### 1. Thay đổi cấu hình hiện có
Tìm file tương ứng trong `modules/system/features/` (cho hệ thống) hoặc `modules/user/features/` (cho ứng dụng/cá nhân) và chỉnh sửa trực tiếp.

### 2. Thêm tính năng mới
Chỉ cần tạo một file `.nix` mới trong thư mục `features/` tương ứng.
Ví dụ: Tạo `modules/user/features/vscode.nix` để cấu hình VS Code.

Cấu trúc file mẫu:
```nix
{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    # Thêm cấu hình của bạn ở đây
  };
}
```

### 3. Kiểm tra lỗi trước khi lưu
Luôn chạy lệnh sau để đảm bảo không có lỗi cú pháp hoặc logic:
```bash
nix flake check
```
