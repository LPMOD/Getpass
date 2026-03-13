#!/data/data/com.termux/files/usr/bin/bash

# ================================================
#   HCCR MAX - One Command Auto Installer
#   by @hccrmax
# ================================================

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
M='\033[0;35m'
B='\033[1m'
X='\033[0m'

INSTALL_DIR="$HOME/hccrmax"
REPO_RAW="https://raw.githubusercontent.com/hccrmax/hccrmax-login/main"

clear
echo ""
echo -e "${M}${B}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║                                          ║"
echo "  ║   ⚡  HCCR MAX - AUTO INSTALLER  ⚡     ║"
echo "  ║             by @hccrmax                  ║"
echo "  ║                                          ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${X}"
echo ""

step() { echo -e "  ${C}[${Y}$1${C}/${Y}6${C}]${X} $2"; }
ok()   { echo -e "       ${G}✅ Done${X}"; echo ""; }
fail() { echo -e "       ${R}❌ $1${X}"; echo ""; }

# ── Step 1: Update ───────────────────────────────
step "1" "Termux update ho raha hai..."
pkg update -y 2>/dev/null 1>/dev/null && ok || fail "Update failed, continuing..."

# ── Step 2: Packages ─────────────────────────────
step "2" "Required packages install ho rahe hain..."
pkg install -y figlet lolcat termux-api curl 2>/dev/null 1>/dev/null && ok || fail "Some packages failed"

# ── Step 3: Download ─────────────────────────────
step "3" "HCCR MAX download ho raha hai..."
mkdir -p "$INSTALL_DIR"
curl -fsSL "$REPO_RAW/banner_login.sh" -o "$INSTALL_DIR/banner_login.sh" 2>/dev/null

if [ ! -s "$INSTALL_DIR/banner_login.sh" ]; then
    fail "Download fail! Internet check karo."
    exit 1
fi
ok

# ── Step 4: Permissions ──────────────────────────
step "4" "Permissions set ho rahi hain..."
chmod +x "$INSTALL_DIR/banner_login.sh"
ok

# ── Step 5: Bashrc ───────────────────────────────
step "5" "Termux startup mein add ho raha hai..."
sed -i '/hccrmax/d' "$HOME/.bashrc" 2>/dev/null
sed -i '/banner_login/d' "$HOME/.bashrc" 2>/dev/null

cat >> "$HOME/.bashrc" << 'BRCEOF'

# ── HCCR MAX Login ── by @hccrmax ──
bash "$HOME/hccrmax/banner_login.sh"
BRCEOF
ok

# ── Step 6: Permissions ──────────────────────────
step "6" "Storage aur camera permission le raha hai..."
echo -e "       ${Y}➡ Popup aaye toh ALLOW karo${X}"
termux-setup-storage 2>/dev/null
ok

# ── Done ─────────────────────────────────────────
echo ""
echo -e "${G}${B}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║                                          ║"
echo "  ║     ✅   INSTALLATION COMPLETE!          ║"
echo "  ║                                          ║"
echo "  ║  👉 Termux band karke dobara kholo       ║"
echo "  ║  👉 Setup wizard shuru hoga              ║"
echo "  ║  👉 ENTER = default value rehega         ║"
echo "  ║  👉 Custom likhna hai toh likho          ║"
echo "  ║                                          ║"
echo "  ║            by @hccrmax                   ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${X}"
echo ""
