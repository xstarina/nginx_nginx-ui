#!/bin/sh

set -ex

# Get architecture
if [ "$(uname)" == 'Linux' ]; then
    case "$(uname -m)" in
    'i386' | 'i686')
        MACHINE='32'
        ;;
    'amd64' | 'x86_64')
        MACHINE='64'
        ;;
    'armv5tel')
        MACHINE='arm32-v5'
        ;;
    'armv6l')
        MACHINE='arm32-v6'
        grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
        ;;
    'armv7' | 'armv7l')
        MACHINE='arm32-v7a'
        grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
        ;;
    'armv8' | 'aarch64')
        MACHINE='arm64-v8a'
        ;;
    *)
        echo "error: The architecture is not supported."
        exit 1
        ;;
    esac
else
    echo "error: The architecture is not supported."
    exit 1
fi

# Get curl
apk add --no-cache curl

# Define variables
RELEASE_LATEST=$(curl -sS -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/0xJacky/nginx-ui/releases/latest" \
    | sed 'y/,/\n/' | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOAD_LINK="https://github.com/0xJacky/nginx-ui/releases/download/${RELEASE_LATEST}/nginx-ui-linux-${MACHINE}.tar.gz"
TAR_FILE="nginx-ui-linux-${MACHINE}.tar.gz"

# Download archive
curl -R -H 'Cache-Control: no-cache' -L -o "${TAR_FILE}" "${DOWNLOAD_LINK}"

# Decompression
mkdir -p ./extract
tar -zxf "${TAR_FILE}" -C ./extract/

echo "Done."
