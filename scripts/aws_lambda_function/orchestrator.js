const handleCreate = require('./create');
const handlePush = require('./push');
const handlePull = require('./pull');

const direction = process.env.INPUT_DIRECTION;
const defaultRegion = process.env.INPUT_REGION;
let resources = [];

try {
    resources = JSON.parse(process.env.INPUT_RESOURCES);
} catch (e) {
    console.error("❌ Failed to parse resources_json.");
    process.exit(1);
}

console.log(`🚀 Starting ${direction.toUpperCase()} for ${resources.length} resources...`);

// 1. Variável para rastrear se houve erros em alguma lambda
let hasErrors = false; 

for (const res of resources) {
    const resourceData = {
        funcId: res.function_arn || res.id,
        folder: res.folder_path || res.git_path,
        region: res.region || defaultRegion,
        runtime: (res.runtime || '').trim()
    };

    console.log(`\n---------------------------------------------------`);
    console.log(`📦 Resource: ${resourceData.funcId}`);
    console.log(`📂 Folder: ${resourceData.folder}`);
    console.log(`⚙️ Runtime: ${resourceData.runtime || 'Unknown'}`);

    try {
        switch (direction) {
            case 'create':
                handleCreate(resourceData);
                break;
            case 'push':
                handlePush(resourceData);
                break;
            case 'pull':
                handlePull(resourceData);
                break;
            default:
                throw new Error(`Unknown direction: ${direction}`);
        }
    } catch (error) {
        // 2. Apenas loga o erro e marca que houve problema, mas NÃO da process.exit(1) aqui!
        console.error(`❌ Failed to process ${resourceData.funcId}:`, error.message);
        hasErrors = true; 
    }
}

// 3. No final de tudo, verifica se teve erro. 
// Se teve, falha o pipeline para você saber que algo deu errado, mas só após tentar TODAS.
if (hasErrors) {
    console.error(`\n⚠️ Finished with errors. Some resources failed during ${direction}.`);
    process.exit(1);
} else {
    console.log(`\n✅ All resources processed successfully!`);
}
