{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aspects.utilities.enable {
    services = {
      power-profiles-daemon.enable = false;

      tlp = {
        enable = true;
        settings = {
          # Ngưỡng sạc pin: Bắt đầu sạc khi dưới 40%, dừng khi đạt 85%
          START_CHARGE_THRESH_BAT0 = 40;
          STOP_CHARGE_THRESH_BAT0 = 85;

          # Chế độ điều tiết xung nhịp CPU: powersave cho phép tự động điều chỉnh linh hoạt
          CPU_SCALING_GOVERNOR_ON_AC = "powersave";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          # Ưu tiên năng lượng/hiệu suất (EPP): default cho AC (cân bằng), power cho BAT (tiết kiệm điện)
          CPU_ENERGY_PERF_POLICY_ON_AC = "default";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

          # Tắt tự động tạm dừng USB (tránh lỗi ngắt kết nối thiết bị ngoại vi)
          USB_AUTOSUSPEND = 0;
        };
      };
    };
  };
}
