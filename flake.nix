{
  description = "LaTeX Document Demo";
  inputs = {
    # nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-medium latex-bin latexmk
            chngcntr hyperref pdftexcmds infwarerr kvoptions parskip
            etoolbox pgf epstopdf-pkg todonotes metafont
            moreverb amsmath subfig psnfss babel-english
            caption minted chemfig geometry eso-pic
            float datetime2 microtype biblatex titlesec
            fancyhdr fvextra catchfile xstring lineno framed
            fancyvrb upquote simplekv tracklang biblatex-ieee
            helvetic
            import csquotes glossaries acronym
            ;
          # inherit (pkgs.texlive) scheme-medium chngcntr ;
        };
        pygments = pkgs.python38Packages.pygments;
      in
      rec {
        packages = {
          inherit tex pygments;
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "latex-demo-document";
            src = self;
            buildInputs = [ pkgs.coreutils tex ];
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath buildInputs}";
              mkdir -p .cache/texmf-var
              env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                latexmk -interaction=nonstopmode -pdf -lualatex \
                -shell-escape main.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp main.pdf $out/
            '';
          };
        };
        devShell = pkgs.mkShell {
          packages = [ tex pygments ];
        };
        defaultPackage = packages.document;
      });
}
