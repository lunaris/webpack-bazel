# https://github.com/bazelbuild/rules_nodejs/blob/c2256c58932cc4d84281b4e5709ef304a1c613eb/packages/labs/webpack/src/webpack_bundle.bzl

def _webpack_bundle(ctx):
    ctx.actions.run(
        inputs = ctx.files.srcs + [ctx.file.config],
        executable = ctx.executable.webpack,
        outputs = ctx.outputs.outputs,
        arguments = ["--mode", "development"],
        progress_message = "Bundling with Webpack...",
    )
    return [DefaultInfo()]


webpack_bundle = rule(
    implementation = _webpack_bundle,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "config": attr.label(allow_single_file = True, mandatory = True),
        "outputs": attr.output_list(mandatory = True),
        "webpack": attr.label(
            default = "@npm//webpack-cli/bin:webpack-cli",
            executable = True,
            cfg = "host"
        ),
    },
)
