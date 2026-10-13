{ pkgs ?  import <nixpkgs> {}
, firmware ? import ../src {}
}:

let
  config = ./.;

  go60_left = firmware.zmk.override {
    board = "go60_lh";
    shield = "go60_lh_peripheral";
    keymap = "${config}/go60_lh.keymap";
    kconfig = "${config}/go60.conf";
    extraModules = [ "${config}" ];
  };
  go60_right = firmware.zmk.override {
    board = "go60_rh";
    keymap = "${config}/go60.keymap";
    kconfig = "${config}/go60.conf";
  };
  go60_combined = firmware.combine_uf2 go60_left go60_right "go60";

  go60_dongle = firmware.zmk.override {
    board = "nice_nano_v2";
    shield = "go60_dongle";
    keymap = "${config}/go60.keymap";
    kconfig = "${config}/boards/shields/go60_dongle/go60_dongle.conf";
    extraModules = [ "${config}" ];
  };

  reset_left = firmware.zmk.override { board = "go60_lh"; shield = "settings_reset"; };
  reset_right = firmware.zmk.override { board = "go60_rh"; shield = "settings_reset"; };
  reset_combined = firmware.combine_uf2 reset_left reset_right "settings_reset";

  reset_dongle = firmware.zmk.override { board = "nice_nano_v2"; shield = "settings_reset"; };

in pkgs.runCommandNoCC "go60_output" {} ''
  mkdir -p $out
  cp ${go60_combined}/go60.uf2 $out/go60.uf2
  cp ${reset_combined}/settings_reset.uf2 $out/settings_reset.uf2
  cp ${go60_dongle}/zmk.uf2 $out/go60_dongle.uf2
  cp ${reset_dongle}/zmk.uf2 $out/settings_reset_dongle.uf2
''
