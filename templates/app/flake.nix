{
  inputs.zephyr-devshell.url = "github:colinbdclark/zephyr-devshell";

  outputs =
    { zephyr-devshell, ... }:
    {
      devShells = zephyr-devshell.lib.forAllSystems (system: {
        default = zephyr-devshell.lib.mkDevShell {
          inherit system;
          extraPackages = pkgs: [ pkgs.probe-rs-tools ];
        };
      });
    };
}
