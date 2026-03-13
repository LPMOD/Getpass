#!/data/data/com.termux/files/usr/bin/bash

# ╔══════════════════════════════════════════════╗
# ║     HCCR MAX - One Command Installer         ║
# ║              by @hccrmax                     ║
# ╚══════════════════════════════════════════════╝

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
M='\033[0;35m'
B='\033[1m'
DIM='\033[2m'
X='\033[0m'

INSTALL_DIR="$HOME/hccrmax"
REPO_RAW="https://raw.githubusercontent.com/hccrmax/hccrmax-login/main"

TW=$(tput cols 2>/dev/null || echo 50)
[ "$TW" -gt 58 ] && TW=58
W1=$((TW - 4))
hline() { printf '═%.0s' $(seq 1 $W1); }
box_top() { echo -e "  ${1}╔$(hline)╗${X}"; }
box_bot() { echo -e "  ${1}╚$(hline)╝${X}"; }
box_text() {
    local text="$1" color="${2:-$X}" bc="${3:-$X}"
    local tlen=${#text}
    local pad=$(( (W1 - tlen) / 2 ))
    local rpad=$(( W1 - tlen - pad ))
    printf "  ${bc}║${X}${color}%${pad}s${text}%${rpad}s${X}${bc}║${X}\n" "" ""
}

clear
echo ""
box_top "${M}${B}"
box_text "" "" "${M}${B}"
box_text "⚡   HCCR MAX - AUTO INSTALLER   ⚡" "${M}${B}" "${M}${B}"
box_text "by @hccrmax" "${DIM}" "${M}${B}"
box_text "" "" "${M}${B}"
box_bot "${M}${B}"
echo ""

step() {
    echo -e "  ${C}[${Y}$1/6${C}]${X}${B} $2${X}"
}
ok()   { echo -e "       ${G}✅ Done${X}"; echo ""; }
fail() { echo -e "       ${R}❌ $1${X}"; echo ""; }

# 1. Update
step 1 "Termux update..."
pkg update -y 2>/dev/null 1>/dev/null
ok

# 2. Packages
step 2 "Packages install ho rahe hain..."
pkg install -y figlet lolcat termux-api curl 2>/dev/null 1>/dev/null
# Check critical ones
if ! command -v curl &>/dev/null; then
    fail "curl install fail! Network check karo."
    exit 1
fi
ok

# 3. Download
step 3 "HCCR MAX download ho raha hai..."
mkdir -p "$INSTALL_DIR"

curl -fsSL \
    --retry 3 \
    --retry-delay 2 \
    --connect-timeout 15 \
    "$REPO_RAW/banner_login.sh" \
    -o "$INSTALL_DIR/banner_login.sh" 2>/dev/null

if [ ! -s "$INSTALL_DIR/banner_login.sh" ]; then
    fail "Download fail! Check karo:"
    echo -e "  ${Y}  1. Internet connection${X}"
    echo -e "  ${Y}  2. GitHub username sahi hai?${X}"
    echo -e "  ${Y}  URL: ${REPO_RAW}/banner_login.sh${X}"
    echo ""
    exit 1
fi

# Verify it's a bash script
if ! head -1 "$INSTALL_DIR/banner_login.sh" | grep -q "bash"; then
    fail "Downloaded file corrupt! (HTML page mili, script nahi)"
    echo -e "  ${Y}  GitHub pe files upload hain? Check karo.${X}"
    rm -f "$INSTALL_DIR/banner_login.sh"
    exit 1
fi
ok

# 4. Permissions
step 4 "Permissions set ho rahi hain..."
chmod +x "$INSTALL_DIR/banner_login.sh"
ok

# 5. Bashrc
step 5 "Termux startup mein add ho raha hai..."
# Clean old entries
sed -i '/# HCCR MAX/d' "$HOME/.bashrc" 2>/dev/null
sed -i '/hccrmax/d' "$HOME/.bashrc" 2>/dev/null
sed -i '/banner_login/d' "$HOME/.bashrc" 2>/dev/null

cat >> "$HOME/.bashrc" << 'BRCEOF'
# HCCR MAX Login - by @hccrmax
[ -f "$HOME/hccrmax/banner_login.sh" ] && bash "$HOME/hccrmax/banner_login.sh"
BRCEOF
ok

# 6. Permissions
step 6 "Storage aur camera permission..."
echo -e "       ${Y}➡ Popup aaye to ALLOW karo${X}"
termux-setup-storage 2>/dev/null
sleep 2
ok

# Done!
echo ""
box_top "${G}${B}"
box_text "" "" "${G}${B}"
box_text "✅   INSTALLATION COMPLETE!   ✅" "${G}${B}" "${G}${B}"
box_text "" "" "${G}${B}"
box_text "👉 Termux band karke dobara kholo" "${Y}" "${G}${B}"
box_text "👉 Setup wizard shuru hoga" "${Y}" "${G}${B}"
box_text "👉 ENTER = default value" "${C}" "${G}${B}"
box_text "" "" "${G}${B}"
box_text "by @hccrmax" "${DIM}" "${G}${B}"
box_text "" "" "${G}${B}"
box_bot "${G}${B}"
echo ""
