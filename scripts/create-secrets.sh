#!/usr/bin/env bash

NAME="$1"
NAMESPACE="$2"
KEY_FILE="$3"
CERT_FILE="$4"
DEST_DIR="$5"
PWD_SECRET_NAME="$6"
DB_PWD="$7"


mkdir -p "${DEST_DIR}"



kubectl create secret generic "${PWD_SECRET_NAME}" \
  -n "${NAMESPACE}" \
  --from-literal="password=${DB_PWD}" \
  --dry-run=client \
  --output=yaml > "${DEST_DIR}/${PWD_SECRET_NAME}.yaml"
