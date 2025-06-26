#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "$SCRIPT_DIR/functions.sh"

# Configuración
REPO_DIR="yum-repo"
RPM_DIR="$REPO_DIR/packages"
S3_PATH="yum"

read_env

# Limpieza previa
rm -rf "$REPO_DIR"
mkdir -p "$RPM_DIR"

# Copiar RPMs al directorio del repo
cp $INCOMING_RPM_FOLDER/*.rpm "$RPM_DIR/"

# Firmar todos los RPMs (reemplaza con passphrase si procede)
#echo "Signing RPMs with the GPG key: $GPG_KEY_ID"
#for rpm in "$RPM_DIR"/*.rpm; do
#    rpm --addsign "$rpm"
#done

# Crear metadatos del repo
echo "Creating metadata with createrepo_c... "
createrepo_c --database "$RPM_DIR"

# Signing repomd.xml
REPO_MD="$RPM_DIR/repodata/repomd.xml"
gpg --default-key "$GPG_KEY_ID" --detach-sign --armor "$REPO_MD"

# (opcional) generar también archivo `.asc` plano no-armored
gpg --default-key "$GPG_KEY_ID" --detach-sign "$REPO_MD"

if [ -f $GPG_PUB ]; then
        cp $GPG_PUB "$REPO_DIR/"
fi

# Subir a S3
echo "Sync to S3..."
aws s3 sync "$RPM_DIR/" "s3://$BUCKET/$S3_PATH/" --delete

echo "✅ YUM Repository created and uploaded to s3://$BUCKET/$S3_PATH/"

