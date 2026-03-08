const fs = require('fs');
const path = require('path');
const { run } = require('./utils');

function getBoilerplate(runtime, baseName) {
    const r = (runtime || '').toLowerCase();

    if (r.includes('python')) {
        return [{
            filename: `${baseName}.py`,
            content: `import json\n\ndef lambda_handler(event, context):\n    return {\n        'statusCode': 200,\n        'body': json.dumps('Hello from CloudMan (Python)!')\n    }`
        }];
    }
    if (r.includes('node') || r.includes('js')) {
        return [{
            filename: `${baseName}.js`,
            content: `exports.handler = async (event) => {\n    return {\n        statusCode: 200,\n        body: JSON.stringify('Hello from CloudMan (Node.js)!'),\n    };\n};`
        }];
    }
    if (r.includes('ruby')) {
        return [
            { filename: `${baseName}.rb`, content: `require 'json'\n\ndef lambda_handler(event:, context:)\n    { statusCode: 200, body: JSON.generate('Hello from CloudMan (Ruby)!') }\nend` },
            { filename: 'Gemfile', content: `source 'https://rubygems.org'\n\n# gem 'aws-sdk-s3'` }
        ];
    }
    return null;
}

function handleCreate(resource) {
    const { folder, runtime } = resource;
    console.log('✨ Checking boilerplate support...');

    if (fs.existsSync(folder)) {
        console.log(`Folder '${folder}' already exists. Skipping.`);
        return;
    }
    
    const baseName = path.basename(folder);
    const templates = getBoilerplate(runtime, baseName);

    if (!templates) {
        console.warn(`⚠️ Skipped: Runtime '${runtime}' is not supported for editable boilerplate.`);
        return;
    }
    
    run(`mkdir -p "${folder}"`);

    for (const tmpl of templates) {
        const filePath = path.join(folder, tmpl.filename);
        fs.writeFileSync(filePath, tmpl.content);
        console.log(`✅ Created ${tmpl.filename}`);
    }
}

module.exports = handleCreate;
