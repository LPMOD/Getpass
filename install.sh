#!/data/data/com.termux/files/usr/bin/bash

# ╔══════════════════════════════════════════╗
# ║    HCCR MAX - Auto Installer             ║
# ║         by @hccrmax                      ║
# ╚══════════════════════════════════════════╝

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

REPO_URL="https://github.com/YOURUSER/hccrmax-login/archive/refs/heads/main.zip"
INSTALL_DIR="$HOME/hccrmax"

clear
echo ""
echo -e "${MAGENTA}${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   🚀  HCCR MAX AUTO INSTALLER            ║"
echo "  ║            by @hccrmax                   ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${RESET}"
echo ""

# ── Step 1: Update packages ──────────────
echo -e "${CYAN}[1/6] Updating Termux packages...${RESET}"
pkg update -y &>/dev/null
echo -e "${GREEN}  ✅ Done${RESET}"

# ── Step 2: Install dependencies ─────────
echo -e "${CYAN}[2/6] Installing required packages...${RESET}"
pkg install -y figlet lolcat termux-api git unzip curl &>/dev/null
echo -e "${GREEN}  ✅ Done${RESET}"

# ── Step 3: Download project ─────────────
echo -e "${CYAN}[3/6] Downloading HCCR MAX...${RESET}"
mkdir -p "$INSTALL_DIR"
curl -L "$REPO_URL" -o /tmp/hccrmax.zip 2>/dev/null
unzip -o /tmp/hccrmax.zip -d /tmp/hccrmax_extracted &>/dev/null
cp -r /tmp/hccrmax_extracted/hccrmax-login-main/* "$INSTALL_DIR/" 2>/dev/null || \
cp -r /tmp/hccrmax_extracted/*/* "$INSTALL_DIR/" 2>/dev/null
rm -f /tmp/hccrmax.zip
echo -e "${GREEN}  ✅ Done${RESET}"

# ── Step 4: Set permissions ──────────────
echo -e "${CYAN}[4/6] Setting permissions...${RESET}"
chmod +x "$INSTALL_DIR/banner_login.sh"
echo -e "${GREEN}  ✅ Done${RESET}"

# ── Step 5: Add to bashrc ────────────────
echo -e "${CYAN}[5/6] Adding to Termux startup...${RESET}"

# Remove old entry if exists
sed -i '/hccrmax/d' "$HOME/.bashrc" 2>/dev/null

# Add new entry
cat >> "$HOME/.bashrc" << 'EOF'

# HCCR MAX Login Banner - by @hccrmax
bash "$HOME/hccrmax/banner_login.sh"
EOF

echo -e "${GREEN}  ✅ Done${RESET}"

# ── Step 6: Termux permissions ───────────
echo -e "${CYAN}[6/6] Requesting storage & camera permissions...${RESET}"
termux-setup-storage 2>/dev/null
echo -e "${GREEN}  ✅ Done${RESET}"

echo ""
echo -e "${GREEN}${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   ✅  INSTALLATION COMPLETE!             ║"
echo "  ║                                          ║"
echo "  ║   Ab Termux band karke dobara kholo.     ║"
echo "  ║   Setup wizard shuru ho jayega!          ║"
echo "  ║                                          ║"
echo "  ║              by @hccrmax                 ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${RESET}"
echo ""
