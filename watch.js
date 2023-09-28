const fs = require('fs');
const { exec } = require("child_process");

function watch() {
  console.log("Listening for changes...")
  let watcher = fs.watch('README.md', (event, filename) => {
    exec("ahoy readme", (error, stdout, stderr) => {
      console.log(stdout);
    })
    watcher.close()
    setTimeout(() => {
      watch();
    }, 1000);
  })
}

watch()
