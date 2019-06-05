load(
    "@build_bazel_rules_nodejs//internal/common:node_module_info.bzl",
    "NodeModuleSources",
)

load(
    "@build_bazel_rules_nodejs//:defs.bzl",
    "nodejs_binary",
)

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
    bundler_data = [cli] + plugins + loaders

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

    ins, _, ms = ctx.resolve_command(tools = [w.webpack])
    foo(ctx.attr.deps)

    dist = ctx.actions.declare_directory(ctx.attr.dist_dir)
    configurator = ctx.actions.declare_file("configurator.js")

    ctx.actions.expand_template(
        template = ctx.file._configurator_template,
        output = configurator,
        substitutions = {
            "TEMPLATED_path": "\"" + dist.path + "\"",
            "TEMPLATED_resolveLoader_modules": "",
            "TEMPLATED_resolve_modules": "",
        },
    )

    print(configurator.short_path)

    config = ctx.actions.declare_file("webpack.config.js")
    ctx.actions.expand_template(
        template = ctx.file.config,
        output = config,
        substitutions = {
            "@bazelify": configurator.short_path,
        },
    )

    ctx.actions.run(
        executable = w.webpack.files_to_run.executable,
        arguments = [
            "--config", config.path,
        ],
        inputs = [ctx.file.config, configurator] + ctx.files.srcs + ctx.files.deps + ctx.files.tools + ins,
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
        "_configurator_template": attr.label(
            default = "//webpack:bazel.js.template",
            allow_single_file = True,
        ),
    },
    outputs = {
        "bundle": "%{name}.tar",
    },
)

def foo(fs):
  for f in fs:
    if NodeModuleSources in f:
      print(f[NodeModuleSources])

def _webpack_bazel_javascript_configurator_impl(ctx):
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = ctx.outputs.configurator,
        substitutions = {
            "TEMPLATED_path": "\"\"",
            "TEMPLATED_resolveLoader_modules": "",
            "TEMPLATED_resolve_modules": "",
        },
    )

_webpack_bazel_javascript_configurator = rule(
    implementation = _webpack_bazel_javascript_configurator_impl,
    attrs = {
        "_template": attr.label(
            allow_single_file = True,
            default = "//webpack:bazel.js.template",
        ),
    },
    outputs = {
        "configurator": "%{name}.js",
    },
)
