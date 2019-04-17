const path = require("path");
const HtmlPlugin = require("html-webpack-plugin");

module.exports = function(env) {
  return {
    entry: "./src/index.js",
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
};
