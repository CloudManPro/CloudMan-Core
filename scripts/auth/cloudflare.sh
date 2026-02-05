#!/bin/bash

function auth_cloudflare() {
    local auth_json=$1
    echo "☁️ Autenticando Cloudflare via Manifesto..."

    # 1. Extrai o nome da secret que o Frontend já preparou
    local secret_key=$(echo "$auth_json" | jq -r '.secret_name')

    # Fallback de segurança: se o secret_name não existir (manifesto antigo), 
    # usa o account_id mas avisa que pode dar erro de case
    if [ "$secret_key" == "null" ] || [ -z "$secret_key" ]; then
        local acc_id=$(echo "$auth_json" | jq -r '.account_id')
        secret_key="AUTH_CLOUDFLARE_${acc_id}"
        echo "⚠️  Aviso: 'secret_name' ausente. Tentando fallback: $secret_key"
    fi

    echo "🔎 Buscando Secret no GitHub: $secret_key"

    # 2. Busca o valor no contexto de secrets (passado pelo engine.yml)
    local token_value=$(echo "$SECRETS_CONTEXT" | jq -r --arg key "$secret_key" '.[$key]')

    # 3. Validação final
    if [ -z "$token_value" ] || [ "$token_value" == "null" ]; then
        echo "❌ Erro: A secret '$secret_key' não foi encontrada nas configurações do Repositório." >&2
        echo "Verifique se você criou a Secret com este nome exato no GitHub." >&2
        return 1
    fi

    # 4. Configura o Provider
    export CLOUDFLARE_API_TOKEN="$token_value"
    echo "✅ Token configurado com sucesso para a chave detectada."
}
