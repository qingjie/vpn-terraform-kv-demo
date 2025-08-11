import logging, os, requests
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import azure.functions as func

def get_secret(secret_name):
    kv_name = os.environ.get("KEYVAULT_NAME")
    if not kv_name:
        raise Exception("KEYVAULT_NAME not set")
    kv_url = f"https://{kv_name}.vault.azure.net"
    cred = DefaultAzureCredential()
    client = SecretClient(vault_url=kv_url, credential=cred)
    secret = client.get_secret(secret_name)
    return secret.value

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Received ACR webhook event")
    try:
        payload = req.get_json()
        # Filtering could be added here based on payload (image name, tag etc.)
        pat = get_secret("azdo-pat")
        org = os.environ.get("AZDO_ORG")
        project = os.environ.get("AZDO_PROJECT")
        pipeline_id = os.environ.get("AZDO_PIPELINE_ID")
        url = f"https://dev.azure.com/{org}/{project}/_apis/pipelines/{pipeline_id}/runs?api-version=6.0-preview.1"
        headers = { "Content-Type": "application/json" }
        auth = ("", pat)
        body = { "resources": { "repositories": { "self": { "refName": "refs/heads/main" } } } }
        resp = requests.post(url, json=body, headers=headers, auth=auth)
        logging.info(f"Triggered pipeline status: {resp.status_code}")
        return func.HttpResponse("Triggered ADO pipeline", status_code=200)
    except Exception as e:
        logging.error(str(e))
        return func.HttpResponse("Error", status_code=500)
