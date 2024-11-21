// #ddev-generated
const fs = require('fs');
const { exec } = require("child_process");

const timeout = 2000

function watch() {
  console.log("Watching for changes on README.md...")
  let watcher = fs.watch('/var/www/html/README.md', (event, filename) => {
    exec("/var/www/html/.ddev/readme/build.sh", (error, stdout, stderr) => {
      console.log(stdout);
    })
    watcher.close()
    setTimeout(() => {
      watch();
    }, timeout);
  })
}

exec("/var/www/html/.ddev/readme/build.sh", (error, stdout, stderr) => {
  console.log(stdout);
})
setTimeout(() => {
  watch();
}, timeout);
