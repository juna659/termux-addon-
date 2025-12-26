#!/bin/bash
# build.sh FINAL - Termux Addon (all old + big update)
# Author: juna659

ADDON_DIR="$HOME/termux-addon"
BIN_DIR="$ADDON_DIR/bin"
mkdir -p "$BIN_DIR"

echo "Building termux-addon..."

############################
# README.md
############################
cat > "$ADDON_DIR/README.md" <<'EOF'
# Termux Addon
A complete set of useful scripts for Termux.
Use `t-a` command to manage packages (install/list/uninstall/update).
EOF

############################
# t-a launcher
############################
cat > "$BIN_DIR/t-a" <<'EOF'
#!/bin/bash
TARGET_DIR="$PREFIX/bin"
CMD="$1"

show_help() {
    echo "termux-addon (t-a)"
    echo ""
    echo "Usage:"
    echo "  t-a list         → List packages"
    echo "  t-a install      → Run installer"
    echo "  t-a uninstall    → Run uninstaller"
    echo "  t-a update       → Check build.sh update"
    exit 0
}

if [ -z "$CMD" ]; then
    show_help
fi

case "$CMD" in
    list)
        ls "$TARGET_DIR" | grep -v 't-a' | sort
        ;;
    install)
        bash "$HOME/termux-addon/install.sh"
        ;;
    uninstall)
        bash "$HOME/termux-addon/uninstall.sh"
        ;;
    update)
        bash "$HOME/termux-addon/update.sh"
        ;;
    *)
        if [ -f "$TARGET_DIR/$CMD" ]; then
            "$TARGET_DIR/$CMD" "${@:2}"
        else
            echo "Please install the package '$CMD' first using 't-a install'"
        fi
        ;;
esac
EOF
chmod +x "$BIN_DIR/t-a"

############################
# install.sh
############################
cat > "$ADDON_DIR/install.sh" <<'EOF'
#!/bin/bash
ADDON_DIR="$HOME/termux-addon"
BIN_DIR="$ADDON_DIR/bin"
TARGET_DIR="$PREFIX/bin"

echo "Termux Addon Installer"
i=1
scripts=()
for f in "$BIN_DIR"/*.py; do
    name=$(basename "$f" .py)
    echo "[$i] $name"
    scripts+=("$name")
    ((i++))
done

read -p "Select packages to install (example: 1 2 3): " choices
mkdir -p "$TARGET_DIR"
for c in $choices; do
    idx=$((c-1))
    s="${scripts[$idx]}"
    if [ -n "$s" ]; then
        cp "$BIN_DIR/$s.py" "$TARGET_DIR/$s"
        chmod +x "$TARGET_DIR/$s"
        echo "Installed: $s"
    fi
done

# Install t-a launcher
cp "$BIN_DIR/t-a" "$TARGET_DIR/t-a"
chmod +x "$TARGET_DIR/t-a"
echo "Installation complete."
EOF
chmod +x "$ADDON_DIR/install.sh"

############################
# uninstall.sh
############################
cat > "$ADDON_DIR/uninstall.sh" <<'EOF'
#!/bin/bash
TARGET_DIR="$PREFIX/bin"
echo "Termux Addon Uninstaller"
options=($(ls "$TARGET_DIR" | grep -v 't-a' | sort))
options+=("ALL")
i=1
for o in "${options[@]}"; do
    echo "[$i] $o"
    ((i++))
done
read -p "Select packages to uninstall (number): " choice
idx=$((choice-1))
if [ "$idx" -lt ${#options[@]} ]; then
    sel="${options[$idx]}"
    if [ "$sel" == "ALL" ]; then
        for p in "${options[@]}"; do
            [ "$p" != "ALL" ] && rm -f "$TARGET_DIR/$p"
        done
        echo "All packages removed."
    else
        rm -f "$TARGET_DIR/$sel"
        echo "Removed: $sel"
    fi
fi
EOF
chmod +x "$ADDON_DIR/uninstall.sh"

############################
# update.sh
############################
cat > "$ADDON_DIR/update.sh" <<'EOF'
#!/bin/bash
LOCAL="$HOME/termux-addon/build.sh"
REMOTE_URL="https://raw.githubusercontent.com/juna659/termux-addon/main/build.sh"
TMP="/tmp/build.sh.tmp"

curl -s -o "$TMP" "$REMOTE_URL"
if [ $? -ne 0 ]; then
    echo "Error: Cannot fetch remote build.sh"
    exit 1
fi

if ! cmp -s "$LOCAL" "$TMP"; then
    echo "Update available! Run the following to update:"
    echo "curl -s -O $REMOTE_URL && bash build.sh"
else
    echo "Your termux-addon is up to date."
fi
rm -f "$TMP"
EOF
chmod +x "$ADDON_DIR/update.sh"

############################
# Packages (17)
############################

# Function to create python package
create_py() {
cat > "$BIN_DIR/$1.py" <<EOF
#!/usr/bin/env python3
$2
EOF
chmod +x "$BIN_DIR/$1.py"
}

# OLD packages
create_py hello 'print("Hello from termux-addon!")'
create_py sysinfo 'import platform, os; print(f"OS: {platform.system()} {platform.release()}"); print(f"User: {os.getlogin()}")'
create_py netcheck 'import os; print("Network:", "OK" if os.system("ping -c 1 8.8.8.8 > /dev/null") == 0 else "DOWN")'
create_py ipinfo 'import os; print(os.popen("curl -s https://api.ipify.org").read())'
create_py diskinfo 'import shutil, os; t,u,f=shutil.disk_usage("/storage/emulated/0"); gb=lambda x:round(x/1024**3,2); print("Total:",gb(t),"GB"); print("Used :",gb(u),"GB"); print("Free :",gb(f),"GB")'
create_py pingcheck 'import os; h=input("Host: "); print("Reachable" if os.system(f"ping -c 1 {h} > /dev/null")==0 else "Down")'
create_py meminfo 'import psutil; m=psutil.virtual_memory(); gb=lambda x:round(x/1024**3,2); print("Total:",gb(m.total),"GB"); print("Used :",gb(m.used),"GB"); print("Free :",gb(m.available),"GB")'
create_py filesize 'import os; p=input("Path: "); s=0; [s:=s+os.path.getsize(os.path.join(r,x)) for r,d,f in os.walk(p) for x in f if os.path.exists(os.path.join(r,x))]; print("Size:",round(s/1024**2,2),"MB")'

# NEW packages
create_py joke 'import random; print(random.choice(["Debugging is like being a detective.","There are only two hard things in CS.","It works on my machine."]))'
create_py motd 'import random; print(random.choice(["Keep coding.","Stay focused.","Termux power."]))'
create_py cputemp 'try: t=int(open("/sys/class/thermal/thermal_zone0/temp").read())/1000; print("CPU Temp:",t,"°C"); except: print("Not available")'
create_py sysname 'import platform; print(platform.node()); print(platform.release())'
create_py whoami 'import os; print("User:",os.getlogin()); print("Home:",os.path.expanduser("~")); print("Shell:",os.environ.get("SHELL"))'
create_py pathinfo 'import os; print("\\n".join(os.environ["PATH"].split(":")))'
create_py randstr 'import random,string; print("".join(random.choices(string.ascii_letters+string.digits,k=16)))'
create_py countfiles 'import os; p=input("Path: "); c=sum(len(f) for _,_,f in os.walk(p)); print("Files:",c)'
create_py ascii 't=input("Text: "); print("===="); print(t); print("====")'

echo "Termux-addon build complete!"
echo "Run: bash install.sh to select packages and install"
