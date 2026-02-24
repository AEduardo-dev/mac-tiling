# Minimal dummy nix-darwin configuration used purely for evaluation testing.
# This is NOT activated — it is only evaluated (nix build --dry-run) to
# confirm the tiling module compiles without errors.
{
  nix-darwin,
  nixpkgs,
  tilingModule,
  system,
}:
nix-darwin.lib.darwinSystem {
  inherit system;
  modules = [
    tilingModule
    {
      nixpkgs.hostPlatform = system;
      # Satisfy the nix-darwin requirement for a hostname.
      networking.hostName = "ci-test";
      # Enable the tiling module so all sub-module options are exercised.
      modules.tiling.enable = true;
      # Minimal system state version required by nix-darwin.
      system.stateVersion = 5;
    }
  ];
}
