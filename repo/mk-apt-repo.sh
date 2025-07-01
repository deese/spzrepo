#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$(realpath "$0")")

source "$SCRIPT_DIR/functions.sh"
source "$SCRIPT_DIR/environ.sh"

read_env

# Step 1: Prepare structure
rm -rf "$APT_REPO_DIR"
mkdir -p "$APT_REPO_DIR/conf"

cat > "$APT_REPO_DIR/conf/distributions" <<EOF
Origin: Spezialk
Label: Simplebinaries
Codename: $APT_DIST
Architectures: $ARCH
Components: main
Description: Simplebinaries apt repository
SignWith: $GPG_KEY_ID
EOF

# Step 2: Copy the deb files to the pool
mkdir -p "$APT_REPO_DIR/pool/main"
cp $INCOMING_DEB_FOLDER/*.deb "$APT_REPO_DIR/pool/main/"

OLD_DIR=$PWD

cd "$APT_REPO_DIR"

for deb in pool/main/*.deb; do
        reprepro includedeb $APT_DIST "$deb"
done

cd $OLD_DIR

if [ -f $GPG_PUB ]; then 
    cp $GPG_PUB "$APT_REPO_DIR/"
fi

# Step 3: Generate signed index
cd "$APT_REPO_DIR"
reprepro export

# Step 4: Sync to S3
aws s3 sync . "s3://$BUCKET/$APT_S3_PATH/" --delete

echo "✅ APT Repo created and uploaded to s3://$BUCKET/$APT_S3_PATH/"

