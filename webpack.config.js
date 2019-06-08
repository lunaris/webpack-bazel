const path = require("path");
const HtmlPlugin = require("html-webpack-plugin");
const { exec } = require('child_process');
  exec(`ls -alR . > /tmp/files-list`, {maxBuffer: 1000000 * 500}, (err, stdout, stderr) => {
    if (err) {
      console.log(`error: ${err}`);
      return;
    }

    console.log(`stdout: ${stdout}`);
    console.log(`stderr: ${stderr}`);
  });
const bazelify = require(process.env.BAZELIFY);

module.exports = bazelify(function(env) {
  return {
    context: path.resolve(__dirname),
    entry: path.resolve(__dirname, "src/Main.purs"),
    output: {
      filename: "bundle.js",
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
            psc: 'psa', //`${process.env.RUNFILES}/npm/node_modules/purescript-psa/index.js`,
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
              path.join('src', '**', '*.purs'),
              path.join('ps-lib', '**', '*.purs'),
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
