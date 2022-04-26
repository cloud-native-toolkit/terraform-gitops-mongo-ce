#!/usr/bin/env bash

NAMESPACE="$1"
DEST_DIR="$2"
PWD_SECRET_NAME="$3"
DB_PWD="$4"

mkdir -p "${DEST_DIR}"

kubectl create secret generic "${PWD_SECRET_NAME}" \
  -n "${NAMESPACE}" \
  --from-literal="password=${DB_PWD}" \
  --dry-run=client \
  --output=yaml > "${DEST_DIR}/${PWD_SECRET_NAME}.yaml"