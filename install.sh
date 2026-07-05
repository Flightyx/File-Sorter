#!/usr/bin/env bash
# Install script for File-Sorter (file_sort)
# Downloads the correct prebuilt binary for your OS/arch from the latest
# GitHub Release and installs it to a directory on your PATH.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Flightyx/File-Sorter/main/install.sh | sh
#
# Optional environment variables:
#   INSTALL_DIR   Where to place the binary (default: $HOME/.local/bin)

set -euo pipefail

REPO="Flightyx/File-Sorter"
BINARY_NAME="file_sort"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

err() {
  echo "Error: $1" >&2
  exit 1
}

# --- Detect OS ---
os_raw="$(uname -s)"
case "$os_raw" in
  Linux*)  os="linux" ;;
  Darwin*) os="darwin" ;;
  MINGW*|MSYS*|CYGWIN*)
    err "Windows detected. Please download the .exe manually from:
  https://github.com/${REPO}/releases/latest" ;;
  *) err "Unsupported operating system: $os_raw" ;;
esac

# --- Detect architecture ---
arch_raw="$(uname -m)"
case "$arch_raw" in
  x86_64|amd64)   arch="x86_64" ;;
  arm64|aarch64)  arch="aarch64" ;;
  *) err "Unsupported architecture: $arch_raw" ;;
esac

# --- Map to Rust target triple used in release asset names ---
case "${os}-${arch}" in
  linux-x86_64)   target="x86_64-unknown-linux-gnu" ;;
  linux-aarch64)  target="aarch64-unknown-linux-gnu" ;;
  darwin-x86_64)  target="x86_64-apple-darwin" ;;
  darwin-aarch64) target="aarch64-apple-darwin" ;;
  *) err "No prebuilt binary available for ${os}/${arch}" ;;
esac

asset_name="${BINARY_NAME}-${target}"
download_url="https://github.com/${REPO}/releases/latest/download/${asset_name}"

echo "Detected platform: ${os}/${arch} (target: ${target})"
echo "Downloading ${asset_name}..."

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$download_url" -o "${tmp_dir}/${BINARY_NAME}" \
    || err "Download failed. Does a release exist at:
  https://github.com/${REPO}/releases/latest ?"
elif command -v wget >/dev/null 2>&1; then
  wget -q "$download_url" -O "${tmp_dir}/${BINARY_NAME}" \
    || err "Download failed. Does a release exist at:
  https://github.com/${REPO}/releases/latest ?"
else
  err "Neither curl nor wget is available. Please install one and try again."
fi

chmod +x "${tmp_dir}/${BINARY_NAME}"

mkdir -p "$INSTALL_DIR"
mv "${tmp_dir}/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"

echo "Installed ${BINARY_NAME} to ${INSTALL_DIR}/${BINARY_NAME}"

# --- Check if install dir is on PATH ---
case ":${PATH}:" in
  *":${INSTALL_DIR}:"*)
    echo "You're all set. Run '${BINARY_NAME} <path>' to get started."
    ;;
  *)
    echo ""
    echo "Note: ${INSTALL_DIR} is not on your PATH."
    echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo ""
    echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
    echo ""
    ;;
esac
