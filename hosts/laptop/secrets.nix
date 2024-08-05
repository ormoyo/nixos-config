{
  sops.defaultSopsFile = ./secrets/laptop.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}

