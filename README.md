# Elemental

**The component parts of a Nix/OS development system.**

Elemental is a fork of [Hugo's repo](https://github.com/HugoReeves/elemental) I am using to create a configurable, declarative development environment built atop [Nix](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager). I have then modified it to suit my own configuration needs

Elemental is currently setup for userspace configuration using Home Manager.

Configuration in Elemental is dividided into three sections, **Machine Configuration**, **Role Configuration** and **User Configuration**.
Custom derivations are stored under these three sections, the objective is to allow as much configuration to be shared where possible, whilst keeping configuration compartmentalised so that changing the machine, role or user is easily possible without rewritting configuration files.

### Machine

The machine configuration is specific to the individual host system, generally speaking, for each non-homogenous device you manage with Elemental, you should have a separate machine configuration.
Configuration that should be considered 'machine specific' includes things like backup configuration that is depenedent on the systems disk layout, and custom networking software that is specific to the system's hardware.

### Role

The majority of Elemental configuration fits into the role category.
Configuration that should be considered 'role' specific includes anything that touches GUI tools, the desktop environment, and shells or prompts.
The idea here is that two separate machines could me made to use the same role configuration, if you wanted the same desktop environment and general configuration on both machines.

In some situations, it makes sense to also consider the machine type within some of the Role configurations.
An example where this may occur is if you need to reference a machine specific wifi network interface in a desktop status bar configuration.
The component being configured here, the desktop status bar, is definitely a part of the role but it is also neccesary to reference the machine being targeted.
Some situations like this are unavoidable.

### User

User configuration primarily consists of installing the command line utilities the user should have access to, and configuring things like SSH, GPG and Git.

# Usage and Installation

If you would like to adapt Elemental for your own purposes, I would encourage you to fork the repo and begin building your own machine, role and user configurations.

Before installing Elemental, you must install [Home Manager](https://github.com/nix-community/home-manager), see [here for instructions](https://github.com/nix-community/home-manager#installation).

Elemental should be installed to `~/.config/nixpkgs`.

You will need to manually add a file called `home.nix` into the top level of your elemental repo.
This file is where you will set the Machine, Role and User to be used in your configuration, it will be ignored by git by default.
Within this file you should import `./elemental.nix` which defines elemental's configuration options.
You should also import `./home/default.nix` which imports the individual machine, role and user configuration files.

## MacOS Example

The following `home.nix` configuration is for my Macbook Pro

```nix
# ./elemental.nix
{ config, pkgs, lib,... }:

{
  imports = [
    ./elemental.nix

    ./home/default.nix
  ];

  # Let Home Manager install itself
  programs.home-manager.enable = true;
  # Allow unfree
  nixpkgs.config.allowUnfree = true;

  elemental.role = "darwin-laptop";
  elemental.user = "henry";
}
```
