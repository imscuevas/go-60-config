{ pkgs ?  import <nixpkgs> {}
, firmware ? import ../src {}
}:

let
  config = ./.;

  go60_left  = firmware.zmk.override { board = "go60_lh"; keymap = "${config}/go60_lh.keymap"; kconfig = "${config}/go60.conf"; };
  go60_right = firmware.zmk.override { board = "go60_rh"; keymap = "${config}/go60.keymap"; kconfig = "${config}/go60.conf"; };
  go60_combined = firmware.combine_uf2 go60_left go60_right "go60";

  reset_left  = firmware.zmk.override { board = "go60_lh"; shield = "settings_reset"; };
  reset_right = firmware.zmk.override { board = "go60_rh"; shield = "settings_reset"; };
  reset_combined = firmware.combine_uf2 reset_left reset_right "settings_reset";

in pkgs.runCommandNoCC "go60_output" {} ''
  mkdir -p $out
  cp ${go60_combined}/go60.uf2 $out/go60.uf2
  cp ${reset_combined}/settings_reset.uf2 $out/settings_reset.uf2
''
