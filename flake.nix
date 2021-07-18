{
  description = "sp-flash-tool";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs?rev=a7e559a5504572008567383c3dc8e142fa7a8633";
      flake = false;
    };
    flokli = {
      url =
        "github:flokli/nix-packages?rev=c86185d10ff8456110dcfa798497ea9336f56ad0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flokli }:
    let

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ (import "${flokli}") ];
      };
      fontsConf = pkgs.makeFontsConf {
        fontDirectories = [ pkgs.fira-code-symbols pkgs.fira-code ];
      };

    in {
      packages.x86_64-linux.defaultPackage.x86_64-linux =
        pkgs.sp-flash-tool.overrideAttrs (oldAttrs: rec {
          installPhase = oldAttrs.installPhase + ''
            wrapProgram $out/bin/flash_tool \
              --set FONTCONFIG_FILE ${fontsConf} \
              --set GDK_PIXBUF_MODULE_FILE "${pkgs.librsvg}/${pkgs.gdk_pixbuf.moduleDir}.cache"
          '';
        });

      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [ sp-flash-tool ];
        inputsFrom = builtins.attrValues self.packages;
      };
    };
}

