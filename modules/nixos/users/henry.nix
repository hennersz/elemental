{ config, inputs, pkgs, ... }:
{
  nix.settings.trusted-users = [ "henry" ];
  users.users.henry = {
    isNormalUser = true;
    extraGroups = [
      "wheel" "qemu-libvirtd" "libvirtd" "docker"
    ];
    openssh.authorizedKeys.keys = [ 
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDh0Ltk6xlm19gYpVDz9L0PPw7o0yvMRavZTOYmthZCVrG5PmuLeRPlIlF+/+L+oUhXqjvCePVU3uLxZzJ7LQR21W7LfDPAmszttzS/qOPlewYMJdPm1kyPjTl9Vk0CtmiKzwGdXvaIhVyZ0YHsrrvv+z4ERgD8P3grKk120JS5Kh4wOln0+8DRvN05iCE0Y6UiHdsjF3CMh1pENlCKC9eni29/dqu3uqyci4bLrK02LCtLAUpzG/aSzWoUPyGFysFsWwPa6g5tMGtoyZuv7GJgtWXCWyPqFbzz2qvKxlfVNPkIIB82J1tbNwMjpnez8wdHaen7XNTrKpCk5j7uSB7I8F6aoXSpWIKZIECNNTwjh/9N7+KQATnMbce8BOZbQgDTzGBm2Vz7eGY9l2NjLA+GMKl5UWVjKga45JDf4sY+xb9EEjKxfvxXeULS4p2OFY3ehcd1d2P7FXl7B65UYbw3aCaHu6M0KTnZc9NZvg6DMQaNqdr82pd9ttr5NJ2g9TFWl7JanYIs75iflbYOZbp5pM17SXm7OcmI/UOI32OM3/IQPG6BGwLlIMvfHOhP7Oy5hWH0dpjm2/rXhrjYHOCNoNKXjTyoHU0y3koTgPqfmynqVrMDuDt3DZc3G8++PiVqbsH1UYlVIGf6mhWbz1fXQz7cc+xZC2S9rRjvmO2ugw== henry@thor"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+sq6PhzCs5XypQzZht6jKTCqhHoLgD//u18a8fEXQc henry@tyr"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIe2Sicssa5GGoFZ9GgL9GB9uWCYxFZnhiUoTe4jqgKY henry@hel"
    ];
    shell = pkgs.fish;
  };
  security.sudo.extraRules= [
    {  
      users = [ "henry" ];
      commands = [
        { 
          command = "ALL" ;
          options= [ "NOPASSWD" ];
        }
        { 
          command = "ALL" ;
          options= [ "SETENV" ]; 
        }
      ];
    }
  ];
}