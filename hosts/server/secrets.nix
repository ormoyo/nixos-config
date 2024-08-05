{
  sops.defaultSopsFile = ./secrets/server.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}
