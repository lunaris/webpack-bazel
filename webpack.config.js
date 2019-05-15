const path = require("path");
const HtmlPlugin = require("html-webpack-plugin");
const webpackBazel = require("com_habito_rules_webpack/webpack-bazel");

const { exec } = require('child_process');

module.exports = webpackBazel(function(env) {
  exec('ls -alR external', (err, stdout, stderr) => {
    if (err) {
      return;
    }

    console.log(`stdout: ${stdout}`);
    console.log(`stderr: ${stderr}`);
  });
  return {
    context: path.resolve(__dirname),
    entry: path.resolve(__dirname, "./src/index.js"),
    output: {
      filename: "bundle.js",
      path: path.resolve(__dirname, "dist"),
      publicPath: "./" // FIXME
    },

    resolve: {
      extensions: [".purs", ".js"]
    },
    stats: 'verbose',
    module: {
      rules: [
        {
          test: /\.purs$/,
          loader: "purs-loader",
          options: {
            bundle: false, // Don't optimise the bundle while developing
            psc: "psa",
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
            ]
          }
        }
        // {
        //   test: /\.js$/,
        //   use: [
        //     {
        //       loader: "babel-loader",
        //       options: {}
        //     }
        //   ]
        // }
      ]
    },
    plugins: [
      new HtmlPlugin({ template: "src/index.html" })
    ]
  };
});
