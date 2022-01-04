{
  description = "Some nix flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlay = final: prev:
        let
          pkgs = nixpkgs.legacyPackages.${prev.system};
        in
        rec {
          sshping = pkgs.sshping.overrideAttrs (oa : {
           src = pkgs.fetchFromGitHub {
             owner = "spook";
             repo = "sshping";
             rev = "master";
             sha256 = "sha256-H9165WPKW1MV+l59AOdSWk1kRDZ7kiQHd3ggzfQ5SjM=";
           };
          });
        };

      templates = {
        latex = {
          path = ./latex;
          description = "LaTeX template";
        };
      };
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ];
          inherit system;
        };
      in
      rec {

        packages = with pkgs; {
          inherit sshping;
          wakapi = pkgs.buildGoModule rec {
            pname = "wakapi";
            version = "2.0.0-RC1";
            rev = "${version}";
            vendorSha256 = "sha256-NJ8lPauLb5gyIGghft5rtJf8LiJwqTfn94h/r9qM5jI=";

            src = fetchFromGitHub {
              owner = "muety";
              repo = "wakapi";
              inherit rev;
              sha256 = "sha256-zAMbyfZ5Gq7KHy2sHYxxdbqdEWzcE7WTtvjq7q/BGU0=";
            };
          };
        };

        defaultPackage = pkgs.sshping;

        apps = {
          sshping = flake-utils.lib.mkApp { drv = pkgs.sshping; name = "sshping"; };
        };

        defaultApp = apps.sshping;
    });
}
