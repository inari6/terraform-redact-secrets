#!/bin/bash

TERRAFORM_CONFIG="TF_LOG=ERROR"
env $TERRAFORM_CONFIG /opt/terraform $@ 2>&1 | \
  sed -r -e 's/([ ]+)MasterPassword:([ ]+)"[^"]+"/\1MasterPassword:\2<redacted>/' \
  | sed -r -e 's/"SqlPassword".*/"SqlPassword" = "****"<redacted>/g' \
  | sed -r -e 's/API_KEY".*/API_KEY" = "****"<redacted>/g' \
  | sed -r -e 's/AUTH_TOKEN".*/AUTH_TOKEN" = "****"<redacted>/g' \
  | sed -r -e '1h; 1!H; ${ g; s/-----BEGIN PRIVATE KEY.*END PRIVATE KEY-----/"****"<redacted>/p }' \
  | sed -r -e '1h; 1!H; ${ g; s/-----BEGIN CERTIFICATE.*END CERTIFICATE-----/"****"<redacted>/p }'