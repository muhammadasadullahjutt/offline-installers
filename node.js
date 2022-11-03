var fs = require("fs");
var cp = require("child_process");
var path = require("path");

if (process.argv.length != 3) {
  console.log("Usage: %s [package name]", process.argv[1]);
  process.exit(0);
}

var packageName = process.argv[2];

// Copy dependencies to bundleDependencies
function rewritePackageJSON(fileName) {
  var contents = fs.readFileSync(fileName);
  var json = JSON.parse(contents);
  if (json.dependencies) {
    json.bundleDependencies = Object.keys(json.dependencies);
    fs.writeFileSync(fileName, JSON.stringify(json, null, 2));
  }
}

// Install the package from the online registry
cp.exec("npm install " + packageName, function (err, stdout, stderr) {
  console.log(stdout);
  console.error(stderr);

  if (err) {
    console.log("Error executing npm install: ", err);
    process.exit(0);
  }

  // Set bundleDependencies for the package
  rewritePackageJSON(path.join("node_modules", packageName, "package.json"));

  // Create a new .tgz file which bundles all dependencies
  cp.exec(
    "npm pack " + path.join("node_modules", packageName),
    function (err, stdout, stderr) {
      console.log(stdout);
      console.error(stderr);

      if (err) {
        console.log("Error executing npm pack: ", err);
      } else {
        console.log("Bundled package " + packageName);
      }
    }
  );
});
