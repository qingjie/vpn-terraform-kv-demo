# VPN Terraform Demo with Key Vault & Managed Identity (DEV/QA/PROD)

This demo repo contains Terraform, Azure Function, Azure DevOps pipeline and scripts for a corporate VPN environment.
It demonstrates multi-environment (dev/qa/prod) deployment, Terraform backend using Azure Storage (with Private Endpoint),
Key Vault integration, and Azure Function that uses Managed Identity to read secrets from Key Vault.

**NOTE**: Replace `<...>` placeholders before running in your environment.

## Structure
- terraform/: Terraform infra (modules for backend_storage, keyvault, identity, aca)
- envs/: per-environment variable files (dev/qa/prod)
- azure-function/: Function code (uses DefaultAzureCredential to read Key Vault)
- scripts/: helper scripts to deploy per environment and check network
- azure-pipelines.yml: multi-stage pipeline (dev -> qa -> prod)

## Quickstart (example)
1. Connect to corporate VPN.
2. Create a Service Principal and set environment variables used by scripts (ARM_*).
3. Create backend storage for each environment (or run module target for backend_storage).
4. Run deploy scripts, e.g. `./scripts/deploy-terraform.sh dev`
