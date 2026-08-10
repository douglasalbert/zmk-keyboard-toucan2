{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # This pins requirements.txt provided by zephyr-nix.pythonEnv.
    #
    # Must match the Zephyr revision that ZMK's own manifest pins for the
    # `zmk` revision in config/west.yml (currently v0.3, which imports
    # zephyr v3.5.0+zmk-fixes via zmk/app/west.yml) — not whatever ZMK
    # `main` currently tracks. A mismatch here doesn't break evaluation,
    # but it does build a pythonEnv (west, python-devicetree/edtlib, etc.)
    # against the wrong Zephyr API surface, which shows up as CMake errors
    # like "Invalid SHIELD" during `west build` even though the actual
    # west-managed ./zephyr checkout is the correct v3.5.0 one.
    zephyr.url = "github:zmkfirmware/zephyr/v3.5.0+zmk-fixes";
    zephyr.flake = false;

    # Zephyr sdk and toolchain.
    zephyr-nix.url = "github:urob/zephyr-nix";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Devicetree linter; use my fork for nix-package and ZMK-specific tweaks.
    dts-linter.url = "github:urob/dts-linter/zmk";
  };

  outputs = { nixpkgs, zephyr-nix, dts-linter, ... }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        zephyr = zephyr-nix.packages.${system};
        keymap_drawer = pkgs.python3Packages.callPackage ./nix/keymap-drawer.nix {};
        dts-format = pkgs.callPackage ./nix/dts-format.nix {
          dts-linter = dts-linter.packages.${system}.default;
        };
      in {
        default = pkgs.mkShellNoCC {
          packages =
            [
              zephyr.pythonEnv
              (zephyr.sdk-0_16.override {targets = ["arm-zephyr-eabi"];})

              pkgs.cmake
              pkgs.dtc
              pkgs.gcc
              pkgs.ninja
              pkgs.protobuf

              pkgs.just
              pkgs.yq # Make sure yq resolves to python-yq.

              keymap_drawer
              dts-format

              # -- Used by just_recipes and west_commands. Most systems already have them. --
              # pkgs.gawk
              # pkgs.unixtools.column
              # pkgs.coreutils
              # pkgs.diffutils
              # pkgs.findutils
              # pkgs.gnugrep
              # pkgs.gnused
            ];

          env = {
            PYTHONPATH = "${zephyr.pythonEnv}/${zephyr.pythonEnv.sitePackages}:${pkgs.python3Packages.protobuf}/${pkgs.python3.sitePackages}";
          };

          shellHook = ''
            export ZMK_BUILD_DIR=$(pwd)/.build;
            export ZMK_SRC_DIR=$(pwd)/zmk/app;
          '';
        };
      }
    );
  };
}
