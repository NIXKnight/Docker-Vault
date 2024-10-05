#!/bin/sh

apk add --no-cache jq

if [ ! -f $VAULT_INIT_DATA_JSON_FILE ]; then
  echo "Initializing Vault."
  vault operator init -format="json" > $VAULT_INIT_DATA_JSON_FILE
else
  echo "Vault is already initialized."
fi

VAULT_SEAL_STATUS=$(vault status -format="json" | jq -r '.sealed')
if [ "$VAULT_SEAL_STATUS" = "true" ]; then
  echo "Vault is sealed. Proceeding with unsealing..."
  for VAULT_UNSEAL_KEY in $(jq -r '.unseal_keys_b64[]' $VAULT_INIT_DATA_JSON_FILE) ; do
    vault operator unseal $VAULT_UNSEAL_KEY
  done
else
  echo "Vault is already unsealed."
fi
