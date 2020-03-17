with import <nixpkgs> {};
let
  extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./nix/extensions.nix).extensions;
  vscode-with-extensions = pkgs.vscode-with-extensions.override {
    vscodeExtensions = extensions;
  };
in stdenv.mkDerivation {
  name = "env";
  buildInputs = [
    jdk11
    vscode-with-extensions
  ];
} 
# ~/.nix-defexpr/channels/nixpkgs/pkgs/misc/vscode-extensions/update_installed_exts.sh | tee nix/extensions.nix
