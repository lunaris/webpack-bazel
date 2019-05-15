"""Functions for building context useful to Webpack rules."""

WebpackContext = provider(
    doc = "Information about a Webpack build context/environment.",
    fields = {
        "toolchain": """
The Webpack toolchain resolved for the rule.
""",
        "webpack": """
The Webpack executable belonging to the Webpack toolchain resolved for the rule.
""",
    },
)

def webpack_context(ctx):
    """Builds a WebpackContext from the given rule context"""

    toolchain = ctx.toolchains["@com_habito_rules_webpack//webpack:toolchain_type"]

    return WebpackContext(
        toolchain = toolchain,
        webpack = toolchain.webpack,
    )
