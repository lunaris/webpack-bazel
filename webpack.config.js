const HtmlPlugin = require("html-webpack-plugin");
const bazelify = require(process.env.BAZELIFY);
const path = require("path");

module.exports = bazelify(function(env) {
  return {
    context: path.resolve(__dirname),
    entry: path.resolve(__dirname, "src/Main.purs"),
    output: {
      filename: "bundle.js",
    },

    resolve: {
      extensions: [".purs", ".js"]
    },
    module: {
      rules: [
        {
          test: /\.purs$/,
          loader: "purs-loader",
          options: {
            bundle: false, // Don't optimise the bundle while developing
            psc: require.resolve("purescript-psa"),
            pscIde: false,
            pscArgs: {
              "censor-lib": true,
              strict: true,
              stash: true,
              "censor-codes": [
                "ImplicitQualifiedImportReExport",
                "ImplicitQualifiedImport",
                "UserDefinedWarning"
              ]
            },
            src: [
              path.join("src", "**", "*.purs"),
              ...bazelify.dependencyFiles.filter(f => f.endsWith(".purs"))
            ]
          }
        }
      ]
    },
    plugins: [
      new HtmlPlugin({ template: "src/index.html" })
    ]
  };
});
