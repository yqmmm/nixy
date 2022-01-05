# default.nix
{ lib
, rustPlatform
, stdenv
, hostPlatform
, llvmPackages
, rust-bin
}:

let
    cargoToml = (builtins.fromTOML (builtins.readFile ./Cargo.toml));
in
rustPlatform.buildRustPackage rec {
  pname = cargoToml.package.name;
  version = cargoToml.package.version;

  src = ./.;

  nativeBuildInputs = [
    rust-bin.nightly.latest.default
  ];

  cargoSha256 = lib.fakeSha256;

  meta = with lib; {
    description = cargoToml.package.description;
    homepage = cargoToml.package.homepage;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ yqmmm ];
  };
}
