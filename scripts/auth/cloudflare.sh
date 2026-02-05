#!/bin/bash

function auth_cloudflare() {
    # Cloudflare usa Token fixo (Secret), não requer JSON de config complexo
    echo "☁️ Autenticando Cloudflare..."

    if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
        echo "❌ Erro: Secret CLOUDFLARE_API_TOKEN não encontrado." >&2
        return 1
    fi
    
    # Terraform provider cloudflare busca essa variável automaticamente
    export CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN"
}
