#!/bin/sh
# RustBridge installer for macOS and Linux.
#   curl -fsSL https://rustbridge.auduvanttechnologies.com/install.sh | sh
# Downloads the latest rustbridge.jar to ~/.rustbridge and adds a `rustbridge` command to ~/.local/bin.
set -eu

JAR_URL="https://github.com/auduvanttechnologies/rustbridge/releases/latest/download/rustbridge.jar"
HOME_DIR="$HOME/.rustbridge"
BIN_DIR="$HOME/.local/bin"

say() { printf '%s\n' "$*"; }

# Java 21+
if ! command -v java >/dev/null 2>&1; then
  say "RustBridge needs Java 21 or newer. Install it first (macOS: brew install openjdk@21), then rerun this."
  exit 1
fi
JAVA_MAJOR=$(java -version 2>&1 | awk -F'"' '/version/ {print $2}' | cut -d. -f1)
if [ -n "$JAVA_MAJOR" ] && [ "$JAVA_MAJOR" -lt 21 ] 2>/dev/null; then
  say "RustBridge needs Java 21 or newer; found Java $JAVA_MAJOR. Install Java 21 (macOS: brew install openjdk@21)."
  exit 1
fi

# Rust (checked, not required to install)
if ! command -v cargo >/dev/null 2>&1; then
  say "Note: cargo (Rust) was not found. Install it before translating:"
  say "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
fi

# Node (only for TypeScript/JavaScript)
if ! command -v node >/dev/null 2>&1; then
  say "Note: node was not found. Install Node.js 22+ (https://nodejs.org) to translate TypeScript or JavaScript."
fi

mkdir -p "$HOME_DIR" "$BIN_DIR"
say "Downloading rustbridge.jar..."
curl -fsSL "$JAR_URL" -o "$HOME_DIR/rustbridge.jar.tmp"
mv "$HOME_DIR/rustbridge.jar.tmp" "$HOME_DIR/rustbridge.jar"

cat > "$BIN_DIR/rustbridge" <<'EOF'
#!/bin/sh
exec java -jar "$HOME/.rustbridge/rustbridge.jar" "$@"
EOF
chmod +x "$BIN_DIR/rustbridge"

say "Installed: $BIN_DIR/rustbridge"
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    say ""
    say "Add ~/.local/bin to your PATH, then open a new terminal:"
    say "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
    ;;
esac
say ""
say "Next:"
say "  rustbridge selftest"
say "  rustbridge login"
say "  rustbridge translate YourFile.java"
