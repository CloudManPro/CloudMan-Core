#!/bin/bash

function auth_cloudflare() {
    local auth_json=$1
    echo "☁️ Autenticando Cloudflare dinamicamente..."

    # 1. Extrai o ID da conta do manifesto
    local account_id=$(echo "$auth_json" | jq -r '.account_id')

    # 2. Monta o nome esperado da variável de ambiente
    # Ex: AUTH_CLOUDFLARE_bf9638139fc9b9a92fa0334ae15ac3ac
    local expected_var_name="AUTH_CLOUDFLARE_${account_id}"

    # 3. Pega o valor da variável cujo nome está em $expected_var_name
    local token_value="${!expected_var_name}"

    if [ -z "$token_value" ]; then
        echo "❌ Erro: Secret '$expected_var_name' não encontrado no ambiente do GitHub." >&2
        echo "Certifique-se de que o Secret existe e que o Engine tem permissão 'secrets: inherit'." >&2
        return 1
    fi

    # 4. Exporta para o Terraform
    export CLOUDFLARE_API_TOKEN="$token_value"
    echo "✅ Token para conta ${account_id} configurado."
}
