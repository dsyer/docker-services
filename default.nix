with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "env";
  buildInputs = [
    jdk24
    kind
    kubectl
    skaffold
  ];
} 
# ~/.nix-defexpr/channels/nixpkgs/pkgs/misc/vscode-extensions/update_installed_exts.sh | tee nix/extensions.nix
