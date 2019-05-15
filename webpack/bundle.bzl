load("@build_bazel_rules_nodejs//internal/common:node_module_info.bzl", "NodeModuleSources")
load("@build_bazel_rules_nodejs//internal/common:module_mappings.bzl", "module_mappings_runtime_aspect")

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

def _webpack_bundle_impl(ctx):
    w = webpack_context(ctx)

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
        inputs = [ctx.file.config] + ctx.files.srcs + ctx.files.deps + ins,
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

webpack_bundle = rule(
    implementation = _webpack_bundle_impl,
    attrs = {
        "config": attr.label(
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
        ),
        "dist_dir": attr.string(
            default="dist"
        ),
        "deps": attr.label_list(
            allow_files = True,
            aspects = [module_mappings_runtime_aspect],
        ),
    },
    outputs = {
        "bundle": "%{name}.tar",
    },
    toolchains = [
        "@com_habito_rules_webpack//webpack:toolchain_type",
    ],
)
