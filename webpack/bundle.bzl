load("@build_bazel_rules_nodejs//:defs.bzl", "nodejs_binary")

load(
    ":context.bzl",
    "webpack_context",
)

WebpackBundleInfo = provider(
    doc = "Information about a Webpack bundle.",
    fields = {
        "bundle": "The bundle `File`.",
    },
)

def webpack_bundle(
    name,
    config,
    srcs,
    cli = "@npm//webpack-cli",
    cli_entry_point = "webpack-cli/bin/cli.js",
    deps = [],
    plugins = [],
    loaders = [],
    tools = []):

    bundler = name + "@cli"
    bundler_data = [cli, "//:webpack-bazel.js"] + plugins + loaders

    nodejs_binary(
        name = bundler,
        entry_point = cli_entry_point,
        data = bundler_data,
    )

    _webpack_bundle(
        name = name,
        bundler = bundler,
        config = config,
        srcs = srcs,
        dist_dir = "dist",
        deps = deps,
        tools = tools,
    )

def _webpack_bundle_impl(ctx):
    w = struct(webpack = ctx.attr.bundler)

    runfiles = w.webpack.data_runfiles.merge(w.webpack.default_runfiles).files.to_list()

    ins, _, ms = ctx.resolve_command(tools = [w.webpack])

    dist = ctx.actions.declare_directory(ctx.attr.dist_dir)
    ctx.actions.run(
        executable = w.webpack.files_to_run.executable,
        arguments = [
            "--config", ctx.file.config.path,
            "--env.output_path", dist.path,
            "--env.test_path", "external/npm/node_modules",
        ],
        inputs = [ctx.file.config] + ctx.files.srcs + ctx.files.deps + ctx.files.tools + ins,
        tools = [w.webpack.files_to_run.runfiles_manifest],
        input_manifests = ms,
        outputs = [dist],
    )

    ctx.actions.run_shell(
        command="tar --create --dereference --directory {dist} -f {dist_tar} .".format(
            dist = dist.path,
            dist_tar = ctx.outputs.bundle.path,
        ),
        inputs = [dist],
        outputs = [ctx.outputs.bundle],
    )

    return [
        WebpackBundleInfo(
            bundle = ctx.outputs.bundle,
        ),
    ]

_webpack_bundle = rule(
    implementation = _webpack_bundle_impl,
    attrs = {
        "bundler": attr.label(
            mandatory = True,
        ),
        "config": attr.label(
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
        ),
        "dist_dir": attr.string(
            mandatory = True,
        ),
        "deps": attr.label_list(
            allow_files = True,
        ),
        "tools": attr.label_list(
            allow_files = True,
        ),
    },
    outputs = {
        "bundle": "%{name}.tar",
    },
)
