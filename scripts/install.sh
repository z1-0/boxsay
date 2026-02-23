#!/bin/sh

set -e

REPO="z1-0/boxsay"
BINARY="boxsay"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; exit 1; }

get_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       error "Unsupported OS: $(uname -s)" ;;
    esac
}

get_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo "x86_64" ;;
        arm64|aarch64) echo "aarch64" ;;
        *)             error "Unsupported arch: $(uname -m)" ;;
    esac
}

get_install_dir() {
    if [ -n "$PREFIX" ]; then
        echo "$PREFIX/bin"
    elif [ -w "/usr/local/bin" ]; then
        echo "/usr/local/bin"
    else
        echo "$HOME/.local/bin"
    fi
}

get_latest_version() {
    if [ -n "$VERSION" ]; then
        echo "$VERSION"
        return
    fi
    
    version=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
    
    if [ -n "$version" ]; then
        echo "$version"
    else
        error "Failed to get latest version. Set VERSION environment variable."
    fi
}

install_binary() {
    os=$(get_os)
    arch=$(get_arch)
    install_dir=$(get_install_dir)
    version=$(get_latest_version)
    filename="${BINARY}-${os}-${arch}-${version}"
    url="https://github.com/${REPO}/releases/download/v${version}/${filename}"
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT
    
    info "Version: $version"
    info "Detected: $os ($arch)"
    info "Installing to: $install_dir"
    info "Downloading $url..."
    
    curl -fsSL "$url" -o "$tmp_dir/$BINARY" || error "Download failed. Make sure the release exists."
    
    mkdir -p "$install_dir"
    
    if [ -w "$install_dir" ]; then
        mv "$tmp_dir/$BINARY" "$install_dir/$BINARY"
        chmod +x "$install_dir/$BINARY"
    else
        info "sudo required for $install_dir"
        sudo mv "$tmp_dir/$BINARY" "$install_dir/$BINARY"
        sudo chmod +x "$install_dir/$BINARY"
    fi
    
    if ! echo "$PATH" | grep -q "$install_dir"; then
        printf "\n"
        warn "Add to your PATH:"
        printf "  export PATH=\"\$PATH:%s\"\n" "$install_dir"
        if [ "$install_dir" = "$HOME/.local/bin" ]; then
            printf "  Add this line to your ~/.bashrc or ~/.zshrc\n"
        fi
    fi
    
    printf "\n"
    info "Done! Try: $BINARY 'Hello, World!'"
}

uninstall() {
    install_dir=$(get_install_dir)
    target="$install_dir/$BINARY"
    
    if [ -f "$target" ]; then
        if [ -w "$install_dir" ]; then
            rm "$target"
        else
            sudo rm "$target"
        fi
        info "Removed $target"
    else
        warn "$BINARY not found in $install_dir"
    fi
}

case "${1:-}" in
    uninstall)
        uninstall
        ;;
    "")
        install_binary
        ;;
    *)
        printf "Usage: curl -fsSL https://raw.githubusercontent.com/%s/main/scripts/install.sh | sh\n" "$REPO"
        printf "\n"
        printf "To uninstall:\n"
        printf "  curl -fsSL https://raw.githubusercontent.com/%s/main/scripts/install.sh | sh -s -- uninstall\n" "$REPO"
        printf "\n"
        printf "To install a specific version:\n"
        printf "  curl -fsSL https://raw.githubusercontent.com/%s/main/scripts/install.sh | VERSION=0.1.0 sh\n" "$REPO"
        printf "\n"
        printf "Environment variables:\n"
        printf "  VERSION   Install specific version (default: latest)\n"
        printf "  PREFIX    Install to PREFIX/bin (default: ~/.local/bin or /usr/local/bin)\n"
        exit 1
        ;;
esac
