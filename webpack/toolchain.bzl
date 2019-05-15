def _webpack_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            name = ctx.label.name,
            mode = ctx.var["COMPILATION_MODE"],
            webpack = ctx.attr.webpack,
        )
    ]

_webpack_toolchain = rule(
    implementation = _webpack_toolchain_impl,
    attrs = {
        "webpack": attr.label(
            mandatory = True,
        ),
    },
)

def webpack_toolchain(
    name,
    webpack,
    **kwargs):

    impl_name = name + "-impl"
    impl_label = ":" + impl_name

    _webpack_toolchain(
        name = impl_name,
        webpack = webpack,
        visibility = ["//visibility:public"],
        **kwargs
    )

    native.toolchain(
        name = name,
        toolchain_type = "@com_habito_rules_webpack//webpack:toolchain_type",
        toolchain = impl_label,
    )
