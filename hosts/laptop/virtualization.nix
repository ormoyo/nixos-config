{pkgs, ...}:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  virtualisation.podman.enable = true;
  programs.virt-manager.enable = true;

  users.users.ormoyo = {
    extraGroups = [ "libvirtd" ];
  };

  environment.systemPackages = with pkgs; [ virtiofsd ];
}
