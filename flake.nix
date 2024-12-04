{
  description = "A developer environment for sync-rb.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    devShells = forEachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      sync-dev = devenv.lib.mkShell {
        inherit inputs pkgs;

        modules = [
          {
            languages.ruby.enable = true;

            enterShell = ''
              bundle install
            '';

            pre-commit.hooks = {
              shellcheck.enable = true; # Setting so git wont scream
            };
          }
        ];
      };
    });
  };
}
