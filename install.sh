#!/bin/sh
# RustBridge installer for macOS and Linux.
#   curl -fsSL https://rustbridge.auduvanttechnologies.com/install.sh | sh
# Downloads the latest rustbridge.jar to ~/.rustbridge and adds a `rustbridge` command to ~/.local/bin.
set -eu

JAR_URL="${RUSTBRIDGE_JAR_URL:-https://github.com/auduvanttechnologies/rustbridge/releases/latest/download/rustbridge.jar}"
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

# Put ~/.local/bin on the PATH for future terminals (like rustup does), unless it's already there.
LINE='export PATH="$HOME/.local/bin:$PATH"'
case "$(basename "${SHELL:-sh}")" in
  zsh)  RC_FILES="$HOME/.zshrc" ;;
  bash) if [ "$(uname)" = "Darwin" ]; then RC_FILES="$HOME/.bash_profile"; else RC_FILES="$HOME/.bashrc"; fi ;;
  fish) RC_FILES="" ;;
  *)    RC_FILES="$HOME/.profile" ;;
esac
ON_PATH=no
case ":$PATH:" in *":$BIN_DIR:"*) ON_PATH=yes ;; esac
if [ "$(basename "${SHELL:-sh}")" = "fish" ]; then
  if [ "$ON_PATH" = no ]; then
    say "Add RustBridge to your PATH (fish):  fish_add_path ~/.local/bin"
  fi
else
  for RC in $RC_FILES; do
    if [ -f "$RC" ] && grep -q '.local/bin' "$RC" 2>/dev/null; then
      :
    else
      printf '\n# Added by the RustBridge installer\n%s\n' "$LINE" >> "$RC"
      say "Added ~/.local/bin to your PATH in $RC"
    fi
  done
fi

say ""
if [ "$ON_PATH" = yes ]; then
  say "Ready. Try:"
else
  say "Open a new terminal window (or run: export PATH=\"\$HOME/.local/bin:\$PATH\"), then try:"
fi
say "  rustbridge selftest"
say "  rustbridge login"
say "  rustbridge translate YourFile.java   (or .ts / .js)"
