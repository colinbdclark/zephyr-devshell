{
  description = "Reusable Nix development environment and project template for Zephyr RTOS-based applications";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zephyr = {
      url = "github:zephyrproject-rtos/zephyr/v4.4.2";
      flake = false;
    };

    zephyr-nix = {
      url = "github:nix-community/zephyr-nix";
      # Use the version of zephyr defined above, not the one zephyr-nix declares.
      inputs.zephyr.follows = "zephyr";
    };
  };

  outputs =
    { nixpkgs, zephyr-nix, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
        "riscv64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      defaultTargets = [
        "arm-zephyr-eabi"
        "x86_64-zephyr-elf"
      ];

      mkDevShell =
        {
          system,
          targets ? defaultTargets,
          extraPythonPackages ? _ps: [ ],
          extraPackages ? _pkgs: [ ],
          shellHook ? "",
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          zephyr = zephyr-nix.packages.${system};
          sdk = zephyr.sdk-1_0.override { inherit targets; };
          pythonEnv = zephyr.pythonEnv.override { extraPackages = extraPythonPackages; };
        in
        pkgs.mkShell {
          name = "zephyr";

          packages = [
            sdk
            pythonEnv

            pkgs.cmake
            pkgs.ninja
            pkgs.gperf
            pkgs.ccache
            pkgs.dtc
            pkgs.qemu
            pkgs.openocd
            pkgs.bossa
            pkgs.file
            pkgs.git
            pkgs.gawk
            pkgs.which
            pkgs.probe-rs-tools
            pkgs.tio
          ]
          ++ extraPackages pkgs;

          shellHook = ''
            export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
            export PYTHONNOUSERSITE=1
            unset PYTHONPATH

            if [ -z "''${ZEPHYR_BASE:-}" ]; then
                _topdir="$(west topdir 2>/dev/null || true)"
                _zbase="$(west config zephyr.base 2>/dev/null || true)"
                if [ -n "$_topdir" ] && [ -n "$_zbase" ] && [ -d "$_topdir/$_zbase" ]; then
                    export ZEPHYR_BASE="$_topdir/$_zbase"
                    export CMAKE_PREFIX_PATH="$ZEPHYR_BASE/share/zephyr-package:''${CMAKE_PREFIX_PATH:-}"
                fi
                unset _topdir _zbase
            fi

            if [[ $- == *i* ]]; then
              source <(west completion bash)
            fi
          ''
          + shellHook;
        };
    in
    {
      lib = {
        inherit
          mkDevShell
          defaultTargets
          systems
          forAllSystems
          ;
      };

      devShells = forAllSystems (system: {
        default = mkDevShell { inherit system; };
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      templates.default = {
        path = ./templates/app;
        description = "Zephyr west workspace application with a Nix devShell";
      };
    };
}
