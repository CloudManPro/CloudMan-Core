const fs = require('fs');
const { run } = require('./utils');

function handlePull(resource) {
    const { funcId, folder, region } = resource;
    console.log('🔼 Uploading code to AWS...');
    
    if (!fs.existsSync(folder)) {
         console.warn(`⚠️ Folder '${folder}' does not exist in repo. Skipping.`);
         return;
    }

    const zipName = `deploy_${Date.now()}.zip`;
    run(`cd "${folder}" && zip -r -X -q "../../${zipName}" .`);
    run(`aws lambda update-function-code --function-name "${funcId}" --zip-file fileb://${zipName} --region ${region} --publish`);
    run(`rm ${zipName}`);
}

module.exports = handlePull;
