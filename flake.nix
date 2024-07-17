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
          inherit (pkgs.texlive)

            # scheme-medium latex-bin latexmk
            # chngcntr hyperref pdftexcmds infwarerr kvoptions parskip
            # etoolbox pgf epstopdf-pkg todonotes metafont
            # moreverb amsmath subfig psnfss babel-english
            # caption minted chemfig geometry eso-pic
            # float datetime2 microtype biblatex titlesec
            # fancyhdr fvextra catchfile xstring lineno framed
            # fancyvrb upquote simplekv tracklang biblatex-ieee
            # helvetic
            # import csquotes glossaries acronym
            # graphviz
            # bigfoot
            # xfor mfirstuc
            # datatool
            # tikz-dependency

            scheme-small
            latexmk
            helvetic
            biber
            # Latexdiff
            latexdiff
            latexpand
            git-latexdiff
            epstopdf
            placeins
            # ucs # For utf8 listings
            # For chemfig
            # simplekv

            # Generated using nix-index on sty list from \listfiles
            acronym
            amsfonts
            amsmath
            auxhook
            babel
            babel-english
            biblatex
            biblatex-ieee
            bigfoot
            bigintcalc
            bitset
            caption
            catchfile
            # chemfig
            csquotes
            datatool
            datetime2
            datetime2-english
            environ
            epstopdf-pkg
            eso-pic
            etexcmds
            etoolbox
            fancyhdr
            fancyvrb
            float
            fp
            framed
            fvextra
            geometry
            gettitlestring
            glossaries
            glossaries-english
            graphics
            graphics-cfg
            graphics-def
            graphviz
            hycolor
            hyper
            hyperref
            ifplatform
            iftex
            import
            infwarerr
            intcalc
            kvdefinekeys
            kvoptions
            kvsetkeys
            l3backend
            l3kernel
            l3packages
            latex
            latex-amsmath-dev
            latex-base-dev
            latex-graphics-companion
            latex-graphics-dev
            latex-tools-dev
            latexconfig
            letltxmacro
            lineno
            listings
            listings-ext
            lm
            logreq
            ltxcmds
            makecell
            mfirstuc
            microtype
            minted
            moreverb
            mptopdf
            parskip
            pdfescape
            pdftexcmds
            pgf
            psnfss
            refcount
            rerunfilecheck
            substr
            supertabular
            textcase
            tikz-dependency
            titlesec
            todonotes
            tools
            tracklang
            translator
            trimspaces
            uniquecounter
            upquote
            url
            xcolor
            xfor
            xkeyval
            xstring


            # \listfiles
            # grep -o "^[^ ]*\.sty" thesis/needed_pkgs.txt | sed 's/\.sty//'
            ;
          # inherit (pkgs.texlive) scheme-medium chngcntr ;
        };
        pygments = pkgs.python312Packages.pygments;
      in
      rec {
        packages = {
          inherit tex pygments;
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "my-thesis";
            src = self;
            buildInputs = [ pkgs.coreutils tex pygments ];
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath buildInputs}";
              mkdir -p .cache/texmf-var
              env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                latexmk -interaction=nonstopmode -pdf \
                -shell-escape main.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp main.pdf $out/
            '';
          };
        };
        devShell = pkgs.mkShell {
          packages = [ tex pygments pkgs.biber ];
        };
        defaultPackage = packages.document;
      });
}
