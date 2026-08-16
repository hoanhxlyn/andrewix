{lib, ...}: {
  den.schema.host = {
    options.powerManagement = lib.mkOption {
      default = {};
      type = lib.types.submodule {
        options = {
          profile = lib.mkOption {
            type = lib.types.enum ["performance" "balanced" "power-saver"];
            default = "balanced";
          };
          dim = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.positive;
            default = 60;
          };
          lock = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.positive;
            default = 300;
          };
          monitorOff = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.positive;
            default = 600;
          };
          suspend = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.positive;
            default = 7200;
          };
        };
      };
    };
  };
}
