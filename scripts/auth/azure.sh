#!/bin/bash
source $(dirname "$0")/utils.sh

function auth_azure() {
    local auth_json=$1
    echo "🔷 Autenticando Azure (OIDC)..."

    local client_id=$(echo "$auth_json" | jq -r '.client_id')
    local tenant_id=$(echo "$auth_json" | jq -r '.tenant_id')
    local subscription_id=$(echo "$auth_json" | jq -r '.subscription_id')

    # A aud do Azure é geralmente api://AzureADTokenExchange
    local jwt=$(get_github_oidc_token "api://AzureADTokenExchange")

    # Login usando Azure CLI com o Token OIDC
    az login --service-principal \
        --username "$client_id" \
        --tenant "$tenant_id" \
        --federated-token "$jwt" \
        --output none

    az account set --subscription "$subscription_id"

    # Exporta variáveis para o Terraform (Provider azurerm)
    export ARM_CLIENT_ID="$client_id"
    export ARM_SUBSCRIPTION_ID="$subscription_id"
    export ARM_TENANT_ID="$tenant_id"
    export ARM_USE_OIDC="true"
    export ARM_OIDC_TOKEN="$jwt"
}
