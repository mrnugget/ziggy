{
  description = "Zig dev env";

  # Flake inputs
  inputs = {
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";
    zls-master.url = "github:zigtools/zls/e89b712e69baa7f745d2d146ca3231264978f1d6";
    zls-master.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Flake outputs
  outputs = { self, zig-overlay, zls-master, nixpkgs }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        zig = zig-overlay.packages.${system}.master;
      });

    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs, zig }: {
        default = pkgs.mkShell {
          name = "Ziggy";
          # The Nix packages provided in the environment
          packages = with pkgs; [
            zig
            zls-master.packages."${pkgs.system}".zls
          ];
        };
      });
    };
}
