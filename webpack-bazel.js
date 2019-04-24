const path = require("path");

module.exports = function(cfg) {
  switch (typeof cfg) {
    case "object":
      return function(env, _argv) {
        return Object.assign(cfg, {
          output: {
            path: path.resolve(env.output_path)
          }
        });
      };

    case "function":
      return function(env, argv) {
        var outputPath = env.output_path;
        delete env.output_path;

        return Object.assign(cfg(env, argv), {
          output: {
            path: path.resolve(outputPath)
          }
        });
      };

    default:
      throw "TODO";
  }
};
