{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, aeson, base, bytestring, lib, matplotlib
      , process, shelly, filepath, text, which, time, pkgs
      }:
      mkDerivation {
        pname = "bashScripting";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [
          aeson base bytestring matplotlib process shelly
        ];
        #executableSystemDepends = [ pkgs.arcan.ffmpeg ffmpeg ];
        librarySystemDepends = [ pkgs.ffmpeg pkgs.cabal-install ];
        license = "unknown";
        mainProgram = "bashScripting";
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});
  
in
if pkgs.lib.inNixShell then drv.env else drv

# pkgs.mkShell {
#   buildInputs = [ pkgs.cabal-install pkgs.ffmpeg ];
#   inputsFrom = [ (if pkgs.lib.inNixShell then drv.env else drv) ];
# } 

  #if pkgs.lib.inNixShell then drv.env else drv
