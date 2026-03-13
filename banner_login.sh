#!/data/data/com.termux/files/usr/bin/bash

# ================================================
#   HCCR MAX - Banner Login System
#   by @hccrmax
# ================================================

CONFIG_DIR="$HOME/.hccrmax"
CONFIG="$CONFIG_DIR/config.cfg"
WRONG_FILE="$CONFIG_DIR/.wrongcount"

# ── Colors ───────────────────────────────────────
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
M='\033[0;35m'
W='\033[1;37m'
B='\033[1m'
X='\033[0m'

# ── Voice Engine Warmup ──────────────────────────
warmup_voice() {
    termux-tts-speak -e com.google.android.tts -l en-US -r 1.0 -p 0.8 " " 2>/dev/null &
    sleep 1.8
}

# ── Speak Function ───────────────────────────────
speak() {
    local msg="$1"
    [ -z "$msg" ] && return
    termux-tts-speak -e com.google.android.tts -l en-US -r 1.0 -p 0.8 "$msg" 2>/dev/null &
}

# ── Default Values ───────────────────────────────
set_defaults() {
    BANNER_NAME="HCCR MAX"
    SUBTITLE="MAX"
    LOGIN_BTN="ACCESS SYSTEM"
    BY_LINE="by @hccrmax"
    PASSWORD="hccrmax@123"
    RECOVERY_PASS="hccr@recover"
    V_LOAD="HCCR MAX System Online. Awaiting Authentication."
    V_CORRECT1="Access Granted."
    V_CORRECT2="Welcome Boss. Good to have you back."
    V_WRONG="Access Denied. Invalid Password. Try Again."
    V_LOCKED="Warning. Security Breach Detected. Intruder Alert."
    V_FORGOT="Enter your recovery password to proceed."
    V_REC_OK="Identity Verified. Set your new password."
    V_REC_FAIL="Recovery Failed. Invalid Recovery Key."
    V_NEWPASS="Password updated successfully. System secured."
}

# ── Load Config ──────────────────────────────────
load_config() {
    set_defaults
    [ -f "$CONFIG" ] && source "$CONFIG"
}

# ── Animated Loading ─────────────────────────────
loading_bar() {
    local msg="$1"
    echo -ne "  ${C}${msg}${X} "
    for i in {1..20}; do
        echo -ne "${G}█${X}"
        sleep 0.04
    done
    echo " ${G}✅${X}"
}

# ── Draw Banner ──────────────────────────────────
draw_banner() {
    clear
    echo ""

    if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
        figlet -f banner -w 55 "$BANNER_NAME" 2>/dev/null | lolcat
        echo ""
        echo "        ━━━━━[ $SUBTITLE ]━━━━━" | lolcat
        echo ""
    elif command -v figlet &>/dev/null; then
        echo -e "${R}${B}"
        figlet -f banner -w 55 "$BANNER_NAME" 2>/dev/null
        echo -e "${M}        ━━━━━[ $SUBTITLE ]━━━━━${X}"
        echo ""
    else
        echo -e "${R}${B}"
        echo "  ██╗  ██╗ ██████╗ ██████╗ ██████╗  "
        echo "  ██║  ██║██╔════╝██╔════╝ ██╔══██╗ "
        echo "  ███████║██║     ██║      ██████╔╝  "
        echo "  ██╔══██║██║     ██║      ██╔══██╗  "
        echo "  ██║  ██║╚██████╗╚██████╗ ██║  ██║  "
        echo "  ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝  "
        echo -e "${M}        ━━━━━[ $SUBTITLE ]━━━━━${X}"
        echo ""
    fi

    echo -e "${C}  ╔══════════════════════════════════════════╗${X}"
    echo -e "${C}  ║${X}  ${Y}${B}⚡ SECURE LOGIN REQUIRED${X}               ${C}║${X}"
    echo -e "${C}  ╚══════════════════════════════════════════╝${X}"
    echo ""
}

# ── Login Page ───────────────────────────────────
login_page() {
    draw_banner
    speak "$V_LOAD"

    wrong=0
    [ -f "$WRONG_FILE" ] && wrong=$(cat "$WRONG_FILE" 2>/dev/null || echo 0)

    while true; do
        echo -e "${R}  ┌──────────────────────────────────────────┐${X}"
        printf "${R}  │${X}  ${W}"
        read -rsp "Enter Password...  " typed
        printf "${X}"
        echo ""
        echo -e "${R}  └──────────────────────────────────────────┘${X}"
        echo ""

        if [ "$typed" = "forgot" ]; then
            forgot_flow
            return
        fi

        if [ "$typed" = "$PASSWORD" ]; then
            echo 0 > "$WRONG_FILE"
            echo ""
            echo -e "${G}${B}"
            echo "  ╔══════════════════════════════════════════╗"
            echo "  ║                                          ║"
            echo "  ║       ✅   ACCESS GRANTED   ✅           ║"
            echo "  ║                                          ║"
            echo "  ╚══════════════════════════════════════════╝"
            echo -e "${X}"
            speak "$V_CORRECT1"
            sleep 0.8
            speak "$V_CORRECT2"
            sleep 2
            after_login
            return
        else
            wrong=$((wrong + 1))
            echo "$wrong" > "$WRONG_FILE"
            echo ""
            echo -e "${R}${B}"
            echo "  ╔══════════════════════════════════════════╗"
            echo "  ║                                          ║"
            echo "  ║       ❌   ACCESS DENIED   ❌            ║"
            echo "  ║                                          ║"
            echo "  ╚══════════════════════════════════════════╝"
            echo -e "${X}"
            speak "$V_WRONG"

            if [ "$wrong" -ge 3 ]; then
                echo ""
                echo -e "${Y}${B}  ⚠️  SECURITY ALERT - CAPTURING INTRUDER...${X}"
                speak "$V_LOCKED"
                take_selfie
                echo 0 > "$WRONG_FILE"
                wrong=0
                sleep 1
            fi

            sleep 1
            draw_banner
        fi

        echo -e "  ${Y}  ╔════════════════════════════════════════╗${X}"
        echo -e "  ${Y}  ║${X}  ${G}${B}  ⚡ $LOGIN_BTN ⚡  ${X}               ${Y}║${X}"
        echo -e "  ${Y}  ╚════════════════════════════════════════╝${X}"
        echo ""
        echo -e "  ${C}     [ Forgot Password? → type: forgot ]${X}"
        echo ""
        echo -e "  ${M}              $BY_LINE${X}"
        echo ""
    done
}

# ── After Login ──────────────────────────────────
after_login() {
    clear
    echo ""
    loading_bar "Loading System"
    echo ""

    if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
        figlet -f banner -w 55 "$BANNER_NAME" 2>/dev/null | lolcat
        echo ""
        echo "        ━━━━━[ $SUBTITLE ]━━━━━" | lolcat
        echo ""
    else
        echo -e "${G}${B}"
        echo "  ╔══════════════════════════════════════════╗"
        echo "  ║      ✅  SYSTEM ACCESS GRANTED           ║"
        echo "  ╚══════════════════════════════════════════╝"
        echo -e "${X}"
    fi

    echo ""
    echo -e "  ${M}              $BY_LINE${X}"
    echo ""
}

# ── Silent Selfie ────────────────────────────────
take_selfie() {
    local ts
    ts=$(date +"%Y%m%d_%H%M%S")
    local path="/sdcard/DCIM/Camera/.sec_$ts.jpg"
    if command -v termux-camera-photo &>/dev/null; then
        termux-camera-photo -c 1 "$path" 2>/dev/null &
    fi
}

# ── Forgot Password ──────────────────────────────
forgot_flow() {
    clear
    echo ""
    echo -e "${Y}${B}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║                                          ║"
    echo "  ║       🔑   RECOVERY MODE                 ║"
    echo "  ║                                          ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo -e "${X}"
    echo ""
    speak "$V_FORGOT"

    echo -e "${C}  ┌──────────────────────────────────────────┐${X}"
    printf "${C}  │${X}  ${W}"
    read -rsp "Enter Recovery Password...  " rec
    printf "${X}"
    echo ""
    echo -e "${C}  └──────────────────────────────────────────┘${X}"
    echo ""

    if [ "$rec" = "$RECOVERY_PASS" ]; then
        speak "$V_REC_OK"
        echo -e "${G}${B}  ✅ Identity Verified!${X}"
        echo ""
        printf "  ${W}🔐 New Password: ${X}"
        read -rsp "" newp; echo ""
        printf "  ${W}🔐 Confirm Password: ${X}"
        read -rsp "" conp; echo ""
        echo ""

        if [ "$newp" = "$conp" ] && [ -n "$newp" ]; then
            sed -i "s|^PASSWORD=.*|PASSWORD=\"$newp\"|" "$CONFIG"
            PASSWORD="$newp"
            speak "$V_NEWPASS"
            echo -e "${G}${B}  ✅ Password Updated! Returning to login...${X}"
            sleep 2
        else
            echo -e "${R}  ❌ Passwords don't match! Try again.${X}"
            sleep 2
            forgot_flow
            return
        fi
    else
        speak "$V_REC_FAIL"
        echo -e "${R}${B}  ❌ Invalid Recovery Key!${X}"
        sleep 2
    fi

    login_page
}

# ── First Time Setup ─────────────────────────────
first_setup() {
    clear
    echo ""
    echo -e "${M}${B}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║                                          ║"
    echo "  ║   ⚡  HCCR MAX - FIRST TIME SETUP  ⚡   ║"
    echo "  ║             by @hccrmax                  ║"
    echo "  ║                                          ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo -e "${X}"
    echo ""
    echo -e "  ${Y}💡 Sirf ENTER dabao = default value rahega${X}"
    echo ""

    mkdir -p "$CONFIG_DIR"
    set_defaults

    echo -e "${C}  ━━━━━━━━━━ 🎨 BANNER SETUP ━━━━━━━━━━${X}"
    echo ""

    read -rp "  📌 Banner naam? [${BANNER_NAME}]: " inp
    [ -n "$inp" ] && BANNER_NAME="$inp"

    read -rp "  📌 Subtitle? [${SUBTITLE}]: " inp
    [ -n "$inp" ] && SUBTITLE="$inp"

    read -rp "  📌 Login button naam? [${LOGIN_BTN}]: " inp
    [ -n "$inp" ] && LOGIN_BTN="$inp"

    echo ""
    echo -e "${C}  ━━━━━━━━━━ 🔐 PASSWORD SETUP ━━━━━━━━━━${X}"
    echo ""

    read -rsp "  🔐 Password set karo [${PASSWORD}]: " inp; echo ""
    [ -n "$inp" ] && PASSWORD="$inp"

    read -rsp "  🔑 Recovery password [${RECOVERY_PASS}]: " inp; echo ""
    [ -n "$inp" ] && RECOVERY_PASS="$inp"

    echo ""
    echo -e "${C}  ━━━━━━━━━━ 🔊 VOICE SETUP ━━━━━━━━━━${X}"
    echo -e "  ${Y}Jo likhoge wahi voice bolegi. ENTER = default${X}"
    echo ""

    read -rp "  🔊 Login load hote hi?
     [${V_LOAD}]
     > " inp
    [ -n "$inp" ] && V_LOAD="$inp"

    read -rp "  🔊 Sahi password - line 1?
     [${V_CORRECT1}]
     > " inp
    [ -n "$inp" ] && V_CORRECT1="$inp"

    read -rp "  🔊 Sahi password - line 2?
     [${V_CORRECT2}]
     > " inp
    [ -n "$inp" ] && V_CORRECT2="$inp"

    read -rp "  🔊 Galat password pe?
     [${V_WRONG}]
     > " inp
    [ -n "$inp" ] && V_WRONG="$inp"

    read -rp "  🔊 3 baar galat (security alert)?
     [${V_LOCKED}]
     > " inp
    [ -n "$inp" ] && V_LOCKED="$inp"

    read -rp "  🔊 Forgot password click pe?
     [${V_FORGOT}]
     > " inp
    [ -n "$inp" ] && V_FORGOT="$inp"

    read -rp "  🔊 Recovery sahi hone pe?
     [${V_REC_OK}]
     > " inp
    [ -n "$inp" ] && V_REC_OK="$inp"

    read -rp "  🔊 Recovery galat hone pe?
     [${V_REC_FAIL}]
     > " inp
    [ -n "$inp" ] && V_REC_FAIL="$inp"

    read -rp "  🔊 Naya password set hone pe?
     [${V_NEWPASS}]
     > " inp
    [ -n "$inp" ] && V_NEWPASS="$inp"

    # Save config
    cat > "$CONFIG" << CFGEOF
# HCCR MAX Config - by @hccrmax
BANNER_NAME="$BANNER_NAME"
SUBTITLE="$SUBTITLE"
LOGIN_BTN="$LOGIN_BTN"
BY_LINE="by @hccrmax"
PASSWORD="$PASSWORD"
RECOVERY_PASS="$RECOVERY_PASS"
V_LOAD="$V_LOAD"
V_CORRECT1="$V_CORRECT1"
V_CORRECT2="$V_CORRECT2"
V_WRONG="$V_WRONG"
V_LOCKED="$V_LOCKED"
V_FORGOT="$V_FORGOT"
V_REC_OK="$V_REC_OK"
V_REC_FAIL="$V_REC_FAIL"
V_NEWPASS="$V_NEWPASS"
CFGEOF

    echo ""
    echo -e "${G}${B}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║   ✅  Setup Complete! Loading System...  ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo -e "${X}"
    sleep 1
}

# ── MAIN ENTRY ───────────────────────────────────
load_config

# Warmup voice engine in background
warmup_voice &

if [ ! -f "$CONFIG" ]; then
    first_setup
    load_config
fi

# Small wait for warmup
sleep 0.5

login_page
