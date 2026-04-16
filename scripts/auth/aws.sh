#!/bin/bash
# A correção está na linha abaixo: BASH_SOURCE[0] em vez de $0
source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function auth_aws() {
    local auth_json=$1
    local type=$2 # "backend" ou "target"

    echo "🔶 Autenticando AWS ($type)..."
    
    local role_arn=$(echo "$auth_json" | jq -r '.role_arn')
    local region=$(echo "$auth_json" | jq -r '.region')
    local session_name="CloudMan-${type}"

    local jwt=$(get_github_oidc_token "sts.amazonaws.com")

    local creds=$(aws sts assume-role-with-web-identity \
      --role-arn "$role_arn" \
      --role-session-name "$session_name" \
      --web-identity-token "$jwt" \
      --duration-seconds 900 \
      --region "$region" \
      --output json)

    local key_id=$(echo $creds | jq -r '.Credentials.AccessKeyId')
    local secret=$(echo $creds | jq -r '.Credentials.SecretAccessKey')
    local token=$(echo $creds | jq -r '.Credentials.SessionToken')

    export AWS_ACCESS_KEY_ID="$key_id"
    export AWS_SECRET_ACCESS_KEY="$secret"
    export AWS_SESSION_TOKEN="$token"
    export AWS_REGION="$region"
    
    if [ "$type" == "backend" ]; then
        aws configure set aws_access_key_id "$key_id" --profile backend
        aws configure set aws_secret_access_key "$secret" --profile backend
        aws configure set aws_session_token "$token" --profile backend
        aws configure set region "$region" --profile backend
    fi
}
