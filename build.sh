#!/bin/bash
# Build script for termux-addon
ADDON_DIR="$HOME/termux-addon"

echo "Creating termux-addon structure..."

# Buat direktori utama
mkdir -p "$ADDON_DIR/bin"

# Buat README.md
cat > "$ADDON_DIR/README.md" <<EOL
# Termux Addon
A small set of scripts to enhance Termux experience.
Includes system info, network check, and hello world examples.
EOL

# Buat install.sh
cat > "$ADDON_DIR/install.sh" <<'EOL'
#!/bin/bash
# Safe installer for termux-addon
# This script installs scripts from bin/ to $PREFIX/bin

set -e

echo "Installing termux-addon scripts to $PREFIX/bin..."

mkdir -p "$PREFIX/bin"

for src in bin/*; do
    dest="$PREFIX/bin/$(basename "$src")"

    # Skip if source and destination are the same file
    if [ "$src" -ef "$dest" ]; then
        echo "Skipping $(basename "$src") (already installed)"
        continue
    fi

    # Copy if file does not exist or source is newer
    if [ ! -e "$dest" ] || [ "$src" -nt "$dest" ]; then
        cp "$src" "$dest"
        echo "Installed $(basename "$src")"
    else
        echo "Skipping $(basename "$src") (up-to-date)"
    fi
done

echo "All scripts installed! You can now run them directly."
EOL

chmod +x "$ADDON_DIR/install.sh"

# Buat update.sh
cat > "$ADDON_DIR/update.sh" <<'EOL'
#!/bin/bash
REPO_URL="https://github.com/juna659/version"
LOCAL_VERSION_FILE="$HOME/termux-addon/.version"

LATEST_HASH=$(curl -s "$REPO_URL/commits/main" | grep -oP '(?<=commit/)[a-f0-9]{40}' | head -1)

if [ ! -f "$LOCAL_VERSION_FILE" ]; then
    echo "$LATEST_HASH" > "$LOCAL_VERSION_FILE"
    echo "Termux-addon version file created."
    exit 0
fi

LOCAL_HASH=$(cat "$LOCAL_VERSION_FILE")

if [ "$LATEST_HASH" != "$LOCAL_HASH" ]; then
    echo "Please update the termux-addon to get more experiences!"
    echo "$LATEST_HASH" > "$LOCAL_VERSION_FILE"
else
    echo "Your termux-addon is up to date."
fi
EOL

chmod +x "$ADDON_DIR/update.sh"

# Buat contoh script Python di bin/
cat > "$ADDON_DIR/bin/hello.py" <<'EOL'
#!/usr/bin/env python3
print("Hello from termux-addon!")
EOL

cat > "$ADDON_DIR/bin/sysinfo.py" <<'EOL'
#!/usr/bin/env python3
import os, platform
print(f"OS: {platform.system()} {platform.release()}")
print(f"User: {os.getlogin()}")
EOL

cat > "$ADDON_DIR/bin/netcheck.py" <<'EOL'
#!/usr/bin/env python3
import os
response = os.system("ping -c 1 8.8.8.8 > /dev/null 2>&1")
if response == 0:
    print("Network is reachable")
else:
    print("Network is down")
EOL

chmod +x "$ADDON_DIR/bin/"*

echo "Termux-addon build complete!"
echo "Run '$ADDON_DIR/install.sh' to install scripts."
