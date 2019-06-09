{ ctx }:

with import <nixpkgs> {};

let
  genBazelBuild =
    callPackage <bazel_purescript_wrapper> { ctx = ctx; };

  packagesJSON =
    builtins.fromJSON (builtins.readFile (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/heyhabito/package-sets/master/packages-with-sha256.json";
      sha256 = "0km8pnvn5wlprwc18bw9vng47dang1hp8x24k73njc50l3fi6rhh";
    }));

in {
  purescriptPackages = genBazelBuild packagesJSON;
}
