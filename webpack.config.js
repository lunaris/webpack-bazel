const path = require("path");
const HtmlPlugin = require("html-webpack-plugin");
const webpackBazel = require("./webpack-bazel");

module.exports = webpackBazel(function(env) {
  return {
    context: path.resolve(__dirname),
    entry: path.resolve(__dirname, "./src/index.js"),
    output: {
      filename: "bundle.js",
      path: path.resolve(__dirname, "dist"),
      publicPath: "./" // FIXME
    },
    module: {
      rules: [
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
    plugins: [new HtmlPlugin({ template: "src/index.html" })]
  };
});
