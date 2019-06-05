var M = require("hello-world-npm");

exports.someForeignString = (function () {
  console.log(M.helloWorld());
  return M.helloWorld();
})();
