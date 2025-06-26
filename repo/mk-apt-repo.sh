#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "$SCRIPT_DIR/functions.sh"
    


# Configuración
REPO_DIR="apt-repo"
GPG_PUB="pubkey.gpg"
DIST="plucky"                
ARCH="amd64"
S3_PATH="apt"

read_env

# Step 1: Prepare structure
rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR/conf"

cat > "$REPO_DIR/conf/distributions" <<EOF
Origin: Spezialk
Label: Simplebinaries
Codename: $DIST
Architectures: $ARCH
Components: main
Description: Simplebinaries apt repository
SignWith: $GPG_KEY_ID
EOF

# Step 2: Copy the deb files to the pool
mkdir -p "$REPO_DIR/pool/main"
cp $INCOMING_DEB_FOLDER/*.deb "$REPO_DIR/pool/main/"

if [ -f $GPG_PUB ]; then 
    cp $GPG_PUB "$REPO_DIR/"
fi

# Step 3: Generate signed index
cd "$REPO_DIR"
reprepro export

# Step 4: Sync to S3
aws s3 sync . "s3://$BUCKET/$S3_PATH/" --delete

echo "✅ APT Repo created and uploaded to s3://$BUCKET/$S3_PATH/"

