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
        plugins = plugins,
        loaders = loaders,
        tools = tools,
    )

def _webpack_bundle_impl(ctx):
    dep_workspaces = _node_module_workspaces_array_literal(ctx.attr.deps)
    plugin_workspaces = _node_module_workspaces_array_literal(ctx.attr.plugins)
    loader_workspaces = _node_module_workspaces_array_literal(ctx.attr.loaders)
    tool_paths = _tool_paths_array_literal(ctx.files.tools)

    w = struct(webpack = ctx.attr.bundler)

    ins, _, ms = ctx.resolve_command(tools = [w.webpack])

    dist = ctx.actions.declare_directory(ctx.attr.dist_dir)

    configurator = ctx.actions.declare_file("configurator.js")

    ctx.actions.expand_template(
        template = ctx.file._configurator_template,
        output = configurator,
        substitutions = {
            "TEMPLATED_path": "\"" + dist.path + "\"",
            "TEMPLATED_dep_workspaces": dep_workspaces,
            "TEMPLATED_plugin_workspaces": plugin_workspaces,
            "TEMPLATED_loader_workspaces": loader_workspaces,
            "TEMPLATED_tool_paths": tool_paths,
        },
    )

    ctx.actions.run(
        executable = w.webpack.files_to_run.executable,
        arguments = [
            "--config", ctx.file.config.path,
        ],
        env = {
            "BAZELIFY": "./" + configurator.path,
        },
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
        "plugins": attr.label_list(
            allow_files = True,
        ),
        "loaders": attr.label_list(
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

def _node_module_workspaces_array_literal(xs):
    workspaces = {}
    for x in xs:
        if NodeModuleSources in x:
            workspaces[x[NodeModuleSources].workspace] = True

    return _array_literal(workspaces.keys())

def _tool_paths_array_literal(tools):
    paths = {}
    for f in tools:
        paths[f.dirname] = True

    return _array_literal(paths.keys())

def _array_literal(xs):
    return "[\"" + "\",\"".join(xs) + "\"]"
