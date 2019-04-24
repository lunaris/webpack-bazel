load("@build_bazel_rules_nodejs//:defs.bzl", "nodejs_binary")

def webpack_bundle(name, config, srcs, dist_dir, plugins = []):
    webpack_exe = name + "@builder"
    nodejs_binary(
        name = webpack_exe,
        entry_point = "webpack-cli/bin/cli.js",
        data = ["@npm//webpack-cli"] + plugins,
    )

    _webpack_bundle(
        name = name,
        webpack = webpack_exe,
        config = config,
        srcs = ["//:webpack-bazel.js"] + srcs,
    )

def _webpack_bundle_impl(ctx):
    dist = ctx.actions.declare_directory(ctx.attr.dist_dir)
    ctx.actions.run(
        executable = ctx.executable.webpack,
        arguments = [
            "--config", ctx.file.config.path,
            "--env.output_path", dist.path,

            # TODO: How do we toggle development mode based on bazel flags?
            "--mode", "production",
        ],
        inputs = [ctx.file.config] + ctx.files.srcs,
        outputs = [dist],
    )

    ctx.actions.run_shell(
        command="tar --create --dereference --directory {dist} -f {dist_tar} .".format(
            dist = dist.path,
            dist_tar = ctx.outputs.dist.path,
        ),
        inputs = [dist],
        outputs = [ctx.outputs.dist],
    )

_webpack_bundle = rule(
    implementation = _webpack_bundle_impl,
    attrs = {
        "webpack": attr.label(
            executable = True,
            cfg = "host",
        ),
        "config": attr.label(
            allow_single_file = True,
        ),
        "srcs": attr.label_list(allow_files=True),
        "dist_dir": attr.string(default="dist"),
    },
    outputs = {
      "dist": "dist.tar",

      # TODO: Docker image output?
    },
)
