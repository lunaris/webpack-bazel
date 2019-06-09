workspace(name = "com_habito_rules_webpack")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "io_tweag_rules_nixpkgs",
    sha256 = "fe9a2b6b92df33dd159d22f9f3abc5cea2543b5da66edbbee128245c75504e41",
    strip_prefix = "rules_nixpkgs-674766086cda88976394fbd608620740857e2535",
    urls = ["https://github.com/tweag/rules_nixpkgs/archive/674766086cda88976394fbd608620740857e2535.tar.gz"],
)

load(
    "@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl",
    "nixpkgs_local_repository",
    "nixpkgs_package",
)

nixpkgs_local_repository(
    name = "nixpkgs",
    nix_file = "//nix:nixpkgs.nix",
)

nixpkgs_package(
    name = "nixpkgs_purescript",
    repositories = {"nixpkgs": "@nixpkgs//:nixpkgs.nix"},
    attribute_path = "purescript",
)

nixpkgs_package(
    name = "nixpkgs_tar",
    repositories = {"nixpkgs": "@nixpkgs//:nixpkgs.nix"},
    attribute_path = "gnutar",
)

http_archive(
    name = "com_habito_rules_purescript",
    strip_prefix = "rules_purescript-0ef7ceb5558e7716d22efa3fb27debda2e6b47c8",
    urls = ["https://github.com/heyhabito/rules_purescript/archive/0ef7ceb5558e7716d22efa3fb27debda2e6b47c8.tar.gz"],
)

load(
    "@com_habito_rules_purescript//purescript:repositories.bzl",
    "purescript_repositories",
)

purescript_repositories()

load(
    "@com_habito_rules_purescript//purescript:nixpkgs.bzl",
    "purescript_nixpkgs_packageset",
)

purescript_nixpkgs_packageset(
    name = "psc-package",
    nix_file = "//nix:purescript-packages.nix",
    base_attribute_path = "purescriptPackages",
    repositories = {"nixpkgs": "@nixpkgs//:nixpkgs.nix"},
)

load(
    "@psc-package-imports//:packages.bzl",
    "purescript_import_packages",
)

purescript_import_packages(
    base_attribute_path = "purescriptPackages",
)

http_archive(
    name = "build_bazel_rules_nodejs",
    sha256 = "3a3efbf223f6de733475602844ad3a8faa02abda25ab8cfe1d1ed0db134887cf",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/0.27.12/rules_nodejs-0.27.12.tar.gz"],
)

load("@build_bazel_rules_nodejs//:defs.bzl", "yarn_install")

yarn_install(
    name = "npm",
    package_json = "//:package.json",
    yarn_lock = "//:yarn.lock",
)

#load("@npm//:install_bazel_dependencies.bzl", "install_bazel_dependencies")
#install_bazel_dependencies()

register_toolchains("//:purescript")
