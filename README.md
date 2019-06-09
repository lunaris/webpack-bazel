# Webpack rules for [Bazel][bazel]

Bazel automates building and testing software. It scales to very large
multi-language projects. This project extends Bazel with build rules for
Webpack.

[bazel]: https://bazel.build
[bazel-getting-started]: https://docs.bazel.build/versions/master/getting-started.html

## Requirements

* [Bazel >= 0.20.0][bazel-getting-started]

## Rules reference

### Bundles

`BUILD.bazel`:

```bzl
webpack_bundle(
    name = "bundle",
    config = "//:webpack.config.js",
    srcs = glob(["src/**"]),
    deps = [
        "//:ps-lib",
        "@psc-package//:prelude",
        "@npm//hello-world-npm",
    ],
    plugins = [
        "@npm//html-webpack-plugin",
    ],
    loaders = [
        "@npm//purs-loader",
        "@npm//purescript-psa",
    ],
    tools = [
        "@nixpkgs_purescript//:bin",
    ],
)
```
