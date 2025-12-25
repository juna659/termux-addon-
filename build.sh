#!/bin/bash
# build.sh - Build termux-addon project with universal t-a launcher

ADDON_DIR="$HOME/termux-addon"
BIN_DIR="$ADDON_DIR/bin"

echo "Creating termux-addon structure..."
mkdir -p "$BIN_DIR"

# ===== README.md =====
cat > "$ADDON_DIR/README.md" <<'EOF'
# Termux Addon
A small set of scripts to enhance your Termux experience.
Use the "t-a" command to manage packages.
EOF

# ===== install.sh =====
cat > "$ADDON_DIR/install.sh" <<'EOF'
#!/bin/bash

ADDON_DIR="$HOME/termux-addon"
BIN_DIR="$ADDON_DIR/bin"
TARGET_DIR="$PREFIX/bin"

echo "Termux Addon Installer"
echo "======================"

i=1
scripts=()

for f in "$BIN_DIR"/*.py; do
    name=$(basename "$f")
    echo "[$i] $name"
    scripts+=("$name")
    ((i++))
done

read -p "Select scripts to install (example: 1 3): " choices

mkdir -p "$TARGET_DIR"

for c in $choices; do
    idx=$((c - 1))
    s="${scripts[$idx]}"
    if [ -n "$s" ]; then
        base="${s%.*}"
        cp "$BIN_DIR/$s" "$TARGET_DIR/$base"
        chmod +x "$TARGET_DIR/$base"
        echo "Installed: $base"
    fi
done

# install t-a launcher
cp "$BIN_DIR/t-a" "$TARGET_DIR/t-a"
chmod +x "$TARGET_DIR/t-a"

echo "Done. Use commands directly, e.g.: pingcheck"
EOF

chmod +x "$ADDON_DIR/install.sh"

# ===== t-a launcher =====
cat > "$BIN_DIR/t-a" <<'EOF'
#!/bin/bash
# t-a universal launcher: auto check and run packages

TARGET_DIR="$PREFIX/bin"

if [ $# -eq 0 ]; then
    echo "Usage: <package>  (managed by t-a)"
    exit 1
fi

CMD="$1"
shift

PACKAGE_PATH="$TARGET_DIR/$CMD"

if [ ! -f "$PACKAGE_PATH" ]; then
    echo "Please install the package first using 't-a install'"
    exit 1
fi

"$PACKAGE_PATH" "$@"
EOF

chmod +x "$BIN_DIR/t-a"

# ===== contoh package pingcheck =====
cat > "$BIN_DIR/pingcheck.py" <<'EOF'
#!/usr/bin/env python3
import os

hosts = input("Enter hosts separated by space: ").split()
for host in hosts:
    response = os.system(f"ping -c 1 {host} > /dev/null 2>&1")
    print(f"{host}: {'reachable' if response == 0 else 'down'}")
EOF

chmod +x "$BIN_DIR/"*

echo "Termux-addon build complete!"
echo "Run '$ADDON_DIR/install.sh' to install scripts."
