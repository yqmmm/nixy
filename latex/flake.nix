{
  description = "LaTeX Document Demo";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-minimal latex-bin latexmk;
      };
    in rec {
      packages = {
        document = pkgs.stdenvNoCC.mkDerivation rec {
          name = "Document";
          src = self;
          buildInputs = [ pkgs.coreutils pkgs.texlive.combined.scheme-full pkgs.gnuplot ];
          phases = ["unpackPhase" "buildPhase" "installPhase"];
          buildPhase = ''
            make || true
            make
          '';
          installPhase = ''
            mkdir -p $out
            cp *.pdf $out/
          '';
        };
      };
      defaultPackage = packages.document;
    });
}
