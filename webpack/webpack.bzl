load(
    ":bundle.bzl",
    _webpack_bundle = "webpack_bundle",
)

load(
    ":toolchain.bzl",
    _webpack_toolchain = "webpack_toolchain",
)

webpack_bundle = _webpack_bundle

webpack_toolchain = _webpack_toolchain
