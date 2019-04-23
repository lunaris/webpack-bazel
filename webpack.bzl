load("@build_bazel_rules_nodejs//:defs.bzl", "nodejs_binary")

def webpack_bundle(
    name,
    config,
    plugins = [],
    srcs = [],
    ):

    nodejs_binary(
        name = name + "@builder",
        entry_point = "webpack-cli/bin/cli.js",
        data = plugins + srcs,
    )

    _webpack_bundle(
        name = name,
        wrapper = name + "@builder",
        config = config,
    )

def _webpack_bundle_impl(ctx):
    ctx.actions.run(
        outputs = [ctx.outputs.o],
        arguments = [
            "--config", ctx.file.config.path,
        ],
        executable = ctx.executable.wrapper,
    )

_webpack_bundle = rule(
    implementation = _webpack_bundle_impl,
    attrs = {
        "wrapper": attr.label(
            executable = True,
            cfg = "host",
        ),
        "config": attr.label(
            allow_single_file = True,
        ),
    },
    outputs = {
        "o": "o.js",
    },
)
