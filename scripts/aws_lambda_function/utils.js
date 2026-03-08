const { execSync } = require('child_process');

function run(cmd) {
    try {
        execSync(cmd, { stdio: 'inherit' }); 
    } catch (e) {
        console.error(`❌ Command failed: ${cmd}`);
        throw e;
    }
}

module.exports = { run };
