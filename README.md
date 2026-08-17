# Zephyr Devshell

This repository contains a Nix devshell for Zephyr RTOS applications. 

It includes the arm-zephyr-eabi and x86_64-zephyr-elf targets.

## Creating a New Zephyr Application

Zephyr applications are contained within a West Workspace. Workspaces should not be versioned, but applications should be.

```
my-workspace/
    .west/             west metadata
    zephyr/            managed by west update
    modules/
    my-app/            your application
```

### 1. Initialize the Application Directory

```console
mkdir -p ~/code/my-workspace/my-app && cd ~/code/my-workspace/my-app
nix flake init -t github:colinbdclark/zephyr-devshell
direnv allow
```

### 2. Configure West

Set `self.path` in your application's `west.yml` to the application's directory name (i.e. `my-app`).

### 3. Initialize West

```console
west init -l .
west update
```

## Building, Running, and Flashing

### List Boards

```console
west boards
```

### Building the Zephyr Application

```console
west build -b <board> .
```

### Clean Rebuild

```console
west build -p always -b <board> .
```

### Running the application

```console
west build -b <board> . -t run
```

### Running the Application in QEMU

```console
west build -b qemu_x86 . -t run
```

### Flashing

With probe-rs:

```console
west flash -r probe-rs
```

Via UF2:

```console
west flash -r uf2
```

## Updating to New Versions of this Repository

```console
nix flake update zephyr-devshel
```

## When Making Changes to this Repository

### Run the Formatter

```console
nix fmt
```

### Testing Unpushed Changes

When testing changes to this devshell from dependent applications, run:

```console
nix develop --override-input zephyr-devshell path:/Users/colin/code/zephyr-devshell
```

## Notes

* Since Nix's Python environment is immutable, additional Python packages must be added through  `extraPythonPackages` in the application's flake. The usual `west packages pip --install` won't work.
* The Zephyr version is defined in two places, which must match: the `zephyr` input in `flake.nix` and in the `revision` property in `templates/app/west.yml`.
* Don't run `nix flake update` with no arguments. It re-resolves zephyr-nix's pinned `nixpkgs`, which breaks the Python environment. Update inputs by name instead: `nix flake update nixpkgs` or `nix flake update zephyr-nix`.
