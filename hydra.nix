{ pkgs, ... }:

let
  hydra = (import <nixpkgs> {}).fetchgit {
      url = https://github.com/NixOS/hydra;
      rev = "bc958c508b8ec777103eac29b137dd138dda1931";
      sha256 = "1h04cnpgvx2h7gbk7rwvr45ybrb09q56q2w02a19962djnkkmsw8";
    };
in
{
    require = [ "${hydra}/hydra-module.nix" ];

    users.extraUsers.root.openssh.authorizedKeys.keys = [ (builtins.readFile ../id_rsa.pub) ];
    users.extraUsers.maurer.openssh.authorizedKeys.keys = [ (builtins.readFile ../id_rsa.pub) ];
    users.extraUsers.maurer.isNormalUser = true;
    networking.firewall.enable = false;

    services.openssh.enable = true;
    services.hydra = {
      enable = true;
      dbi = "dbi:Pg:dbname=hydra;host=localhost;user=hydra;";
      package = (import "${hydra}/release.nix" {}).build.x86_64-linux;
      hydraURL = "https://hydra.aegis.cylab.cmu.edu/";
      listenHost = "localhost";
      port = 3000;
      notificationSender = "hydra@aegis.cylab.cmu.edu";
      logo = null;
      debugServer = false;
    };

    services.postgresql = {
      enable = true;
      authentication = pkgs.lib.mkOverride 10 ''
        host hydra all 127.0.0.1/8 trust
        local all all trust
      '';
    };

    networking.hostName = "hydra";
}
