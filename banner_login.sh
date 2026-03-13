#!/data/data/com.termux/files/usr/bin/bash

# ╔══════════════════════════════════════════════╗
# ║       HCCR MAX - Secure Banner Login         ║
# ║              by @hccrmax                     ║
# ╚══════════════════════════════════════════════╝

CONFIG_DIR="$HOME/.hccrmax"
CONFIG="$CONFIG_DIR/config.cfg"
WRONG_FILE="$CONFIG_DIR/.wc"

# ── Terminal Width ────────────────────────────────
TW=$(tput cols 2>/dev/null || echo 50)
[ "$TW" -gt 58 ] && TW=58
[ "$TW" -lt 36 ] && TW=36
W1=$((TW - 4))

# ── Colors ────────────────────────────────────────
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
M='\033[0;35m'
W='\033[1;37m'
DIM='\033[2m'
B='\033[1m'
X='\033[0m'

# ── Box Helpers ───────────────────────────────────
hline()   { printf '═%.0s' $(seq 1 $W1); }
dline()   { printf '─%.0s' $(seq 1 $W1); }
sline()   { printf ' %.0s' $(seq 1 $W1); }

box_top() { echo -e "  ${1}╔$(hline)╗${X}"; }
box_bot() { echo -e "  ${1}╚$(hline)╝${X}"; }
box_mid() { echo -e "  ${1}║$(sline)║${X}"; }

box_text() {
    local text="$1" color="${2:-$X}" bcolor="${3:-$X}"
    # strip color codes for length
    local clean
    clean=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local tlen=${#clean}
    local pad=$(( (W1 - tlen) / 2 ))
    local rpad=$(( W1 - tlen - pad ))
    printf "  ${bcolor}║${X}${color}%${pad}s${text}%${rpad}s${X}${bcolor}║${X}\n" "" ""
}

# ── Speak ─────────────────────────────────────────
speak() {
    local msg="$1"
    [ -z "$msg" ] && return
    pkill -f "termux-tts-speak" 2>/dev/null
    termux-tts-speak \
        -e com.google.android.tts \
        -l en-US \
        -r 0.92 \
        -p 0.72 \
        "$msg" 2>/dev/null &
}

warmup_voice() {
    termux-tts-speak \
        -e com.google.android.tts \
        -l en-US \
        -r 0.92 \
        -p 0.72 \
        " " 2>/dev/null &
}

# ── Loading Bar ───────────────────────────────────
loading_bar() {
    local msg="$1"
    local bw=$(( W1 - ${#msg} - 5 ))
    [ "$bw" -lt 4 ] && bw=4
    echo -ne "  ${C}${msg}${X} ${DIM}[${X}"
    for i in $(seq 1 $bw); do
        echo -ne "${G}▓${X}"
        sleep 0.03
    done
    echo -e "${DIM}]${X} ${G}✅${X}"
}

# ── Default Values ────────────────────────────────
set_defaults() {
    BANNER_NAME="HCCR MAX"
    SUBTITLE="MAX"
    LOGIN_BTN="ACCESS SYSTEM"
    PASSWORD="hccrmax@123"
    RECOVERY_PASS="hccr@recover"
    V_LOAD="H C C R MAX System online. Awaiting authentication."
    V_CORRECT1="Access granted."
    V_CORRECT2="Welcome back, Boss. Good to have you."
    V_WRONG="Access denied. Invalid credentials. Try again."
    V_LOCKED="Warning. Security breach detected. Initiating lockdown."
    V_FORGOT="Please enter your recovery password to proceed."
    V_REC_OK="Identity verified. Please set your new password."
    V_REC_FAIL="Recovery failed. Invalid recovery key."
    V_NEWPASS="Password updated successfully. System secured."
}

load_config() {
    set_defaults
    [ -f "$CONFIG" ] && source "$CONFIG"
}

# ── Draw Banner ───────────────────────────────────
draw_banner() {
    clear
    echo ""
    if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
        figlet -f banner -w "$TW" "$BANNER_NAME" 2>/dev/null | lolcat
        echo ""
        echo "$(printf '%*s' $(( (TW - ${#SUBTITLE} - 8) / 2 )) '')━━━[ ${SUBTITLE} ]━━━" | lolcat
        echo ""
    elif command -v figlet &>/dev/null; then
        echo -e "${R}${B}"
        figlet -f banner -w "$TW" "$BANNER_NAME" 2>/dev/null
        echo -e "${M}$(printf '%*s' $(( (TW - ${#SUBTITLE} - 8) / 2 )) '')━━━[ ${SUBTITLE} ]━━━${X}"
        echo ""
    else
        echo -e "${R}${B}"
        echo "  ██╗  ██╗ ██████╗ ██████╗ ██████╗ "
        echo "  ██║  ██║██╔════╝██╔════╝ ██╔══██╗"
        echo "  ███████║██║     ██║      ██████╔╝ "
        echo "  ██╔══██║██║     ██║      ██╔══██╗ "
        echo "  ██║  ██║╚██████╗╚██████╗ ██║  ██║ "
        echo "  ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝ "
        echo -e "${M}     ━━━[ ${SUBTITLE} ]━━━${X}"
        echo ""
    fi

    box_top "${Y}"
    box_mid "${Y}"
    box_text "⚡  SECURE AUTHENTICATION REQUIRED  ⚡" "${Y}${B}" "${Y}"
    box_mid "${Y}"
    box_bot "${Y}"
    echo ""
}

# ── Input Box ─────────────────────────────────────
input_box() {
    local prompt="$1"
    local varname="$2"
    local secret="${3:-no}"
    echo -e "  ${R}┌$(dline)┐${X}"
    printf "  ${R}│${X}  ${DIM}${prompt}${X}  "
    if [ "$secret" = "yes" ]; then
        read -rsp "" val
    else
        read -rp "" val
    fi
    echo ""
    echo -e "  ${R}└$(dline)┘${X}"
    echo ""
    eval "$varname=\"\$val\""
}

# ── Login Page ────────────────────────────────────
login_page() {
    draw_banner
    speak "$V_LOAD"

    local wrong=0
    if [ -f "$WRONG_FILE" ]; then
        wrong=$(cat "$WRONG_FILE" 2>/dev/null)
        [[ ! "$wrong" =~ ^[0-9]+$ ]] && wrong=0
    fi

    while true; do
        # Password input
        echo -e "  ${R}┌$(dline)┐${X}"
        printf "  ${R}│${X}  "
        read -rsp "" typed
        echo ""
        echo -e "  ${R}└$(dline)┘${X}"
        echo ""

        # Forgot?
        if [ "$typed" = "forgot" ]; then
            forgot_flow
            return
        fi

        # Correct
        if [ "$typed" = "$PASSWORD" ]; then
            echo 0 > "$WRONG_FILE"
            echo ""
            box_top "${G}"
            box_mid "${G}"
            box_text "✅   A C C E S S   G R A N T E D   ✅" "${G}${B}" "${G}"
            box_mid "${G}"
            box_bot "${G}"
            echo ""
            speak "$V_CORRECT1"
            sleep 0.8
            speak "$V_CORRECT2"
            sleep 1.5
            after_login
            return
        fi

        # Wrong
        wrong=$((wrong + 1))
        echo "$wrong" > "$WRONG_FILE"
        local remain=$((3 - wrong))

        echo ""
        box_top "${R}"
        box_mid "${R}"
        box_text "❌   A C C E S S   D E N I E D   ❌" "${R}${B}" "${R}"
        [ "$remain" -gt 0 ] && \
            box_text "[ ${remain} attempt(s) remaining ]" "${Y}" "${R}"
        box_mid "${R}"
        box_bot "${R}"
        echo ""
        speak "$V_WRONG"

        # 3 strikes
        if [ "$wrong" -ge 3 ]; then
            sleep 0.5
            echo ""
            box_top "${Y}${B}"
            box_text "⚠️   SECURITY BREACH DETECTED   ⚠️" "${Y}${B}" "${Y}${B}"
            box_text "🔒  CAPTURING INTRUDER  🔒" "${R}${B}" "${Y}${B}"
            box_bot "${Y}${B}"
            echo ""
            speak "$V_LOCKED"
            # Silent selfie
            if command -v termux-camera-photo &>/dev/null; then
                local ts
                ts=$(date +"%Y%m%d_%H%M%S")
                termux-camera-photo -c 1 \
                    "/sdcard/DCIM/.security_${ts}.jpg" \
                    2>/dev/null &
            fi
            sleep 2
            echo 0 > "$WRONG_FILE"
            wrong=0
        else
            sleep 1
        fi

        draw_banner

        # Login UI
        echo -e "  ${R}┌$(dline)┐${X}"
        printf "  ${R}│${X}  ${DIM}Enter Password...${X}$(printf ' %.0s' $(seq 1 $((W1 - 19))))${R}│${X}\n"
        echo -e "  ${R}└$(dline)┘${X}"
        echo ""
        echo -e "  ${Y}╔$(hline)╗${X}"
        box_text "  ⚡  ${LOGIN_BTN}  ⚡" "${G}${B}" "${Y}"
        echo -e "  ${Y}╚$(hline)╝${X}"
        echo ""
        echo -e "  ${DIM}${C}  [ Forgot Password → type: forgot ]${X}"
        echo ""
        echo -e "  ${M}$(printf '%*s' $(( (W1 - 10) / 2 )) '')by @hccrmax${X}"
        echo ""

    done
}

# ── After Login ───────────────────────────────────
after_login() {
    clear
    echo ""
    loading_bar "Initializing System  "
    sleep 0.1
    loading_bar "Loading User Profile "
    sleep 0.1
    loading_bar "System Ready         "
    echo ""

    if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
        figlet -f banner -w "$TW" "$BANNER_NAME" 2>/dev/null | lolcat
        echo ""
        echo "$(printf '%*s' $(( (TW - ${#SUBTITLE} - 8) / 2 )) '')━━━[ ${SUBTITLE} ]━━━" | lolcat
        echo ""
    else
        box_top "${G}"
        box_text "✅   SYSTEM ONLINE   ✅" "${G}${B}" "${G}"
        box_bot "${G}"
        echo ""
    fi

    echo -e "  ${M}$(printf '%*s' $(( (W1 - 10) / 2 )) '')by @hccrmax${X}"
    echo ""
}

# ── Forgot Flow ───────────────────────────────────
forgot_flow() {
    clear
    echo ""
    box_top "${Y}${B}"
    box_mid "${Y}${B}"
    box_text "🔑   RECOVERY MODE" "${Y}${B}" "${Y}${B}"
    box_mid "${Y}${B}"
    box_bot "${Y}${B}"
    echo ""
    speak "$V_FORGOT"
    sleep 0.3

    echo -e "  ${C}┌$(dline)┐${X}"
    printf "  ${C}│${X}  "
    read -rsp "" rec
    echo ""
    echo -e "  ${C}└$(dline)┘${X}"
    echo ""

    if [ "$rec" != "$RECOVERY_PASS" ]; then
        speak "$V_REC_FAIL"
        echo -e "  ${R}${B}  ❌  Invalid Recovery Key!${X}"
        sleep 2
        login_page
        return
    fi

    speak "$V_REC_OK"
    echo -e "  ${G}${B}  ✅  Identity Verified!${X}"
    echo ""
    sleep 0.5

    while true; do
        echo -e "  ${C}┌$(dline)┐${X}"
        printf "  ${C}│${X}  ${W}New Password: ${X}"
        read -rsp "" newp
        echo ""
        echo -e "  ${C}└$(dline)┘${X}"
        echo ""

        echo -e "  ${C}┌$(dline)┐${X}"
        printf "  ${C}│${X}  ${W}Confirm Password: ${X}"
        read -rsp "" conp
        echo ""
        echo -e "  ${C}└$(dline)┘${X}"
        echo ""

        if [ -z "$newp" ]; then
            echo -e "  ${R}  ❌  Password empty nahi ho sakta!${X}"
            sleep 1; continue
        fi
        if [ ${#newp} -lt 4 ]; then
            echo -e "  ${R}  ❌  Kam se kam 4 characters chahiye!${X}"
            sleep 1; continue
        fi
        if [ "$newp" != "$conp" ]; then
            echo -e "  ${R}  ❌  Passwords match nahi kiye! Try again.${X}"
            sleep 1; continue
        fi
        break
    done

    sed -i "s|^PASSWORD=.*|PASSWORD=\"$(echo "$newp" | sed 's/"/\\"/g')\"|" "$CONFIG"
    PASSWORD="$newp"

    speak "$V_NEWPASS"
    echo -e "  ${G}${B}  ✅  Password Updated! Returning...${X}"
    sleep 2
    login_page
}

# ── First Time Setup ──────────────────────────────
first_setup() {
    clear
    echo ""
    box_top "${M}${B}"
    box_mid "${M}${B}"
    box_text "⚡  HCCR MAX - FIRST TIME SETUP  ⚡" "${M}${B}" "${M}${B}"
    box_text "by @hccrmax" "${DIM}" "${M}${B}"
    box_mid "${M}${B}"
    box_bot "${M}${B}"
    echo ""
    echo -e "  ${Y}  💡 ENTER = default value rakhega${X}"
    echo -e "  ${Y}  ✏️  Custom chahiye to type karo${X}"
    echo ""

    mkdir -p "$CONFIG_DIR"
    set_defaults

    # Banner
    echo -e "  ${C}${B}━━━━━ 🎨 BANNER SETUP ━━━━━${X}"; echo ""
    read -rp "  📌 Banner naam? [${BANNER_NAME}]: " inp
    [ -n "$inp" ] && BANNER_NAME="$inp"
    read -rp "  📌 Subtitle? [${SUBTITLE}]: " inp
    [ -n "$inp" ] && SUBTITLE="$inp"
    read -rp "  📌 Login button naam? [${LOGIN_BTN}]: " inp
    [ -n "$inp" ] && LOGIN_BTN="$inp"
    echo ""

    # Password
    echo -e "  ${C}${B}━━━━━ 🔐 PASSWORD SETUP ━━━━━${X}"; echo ""
    while true; do
        read -rsp "  🔐 Password set karo [${PASSWORD}]: " inp; echo ""
        if [ -z "$inp" ]; then break
        elif [ ${#inp} -lt 4 ]; then echo -e "  ${R}  ❌ 4+ characters chahiye!${X}"
        else PASSWORD="$inp"; break; fi
    done
    while true; do
        read -rsp "  🔑 Recovery password [${RECOVERY_PASS}]: " inp; echo ""
        if [ -z "$inp" ]; then break
        elif [ ${#inp} -lt 4 ]; then echo -e "  ${R}  ❌ 4+ characters chahiye!${X}"
        else RECOVERY_PASS="$inp"; break; fi
    done
    echo ""

    # Voice
    echo -e "  ${C}${B}━━━━━ 🔊 VOICE SETUP ━━━━━${X}"
    echo -e "  ${DIM}Jo likhoge wahi voice bolegi. ENTER = default.${X}"; echo ""

    read -rp "  🔊 Login load hote hi?
  ${DIM}Default: ${V_LOAD}${X}
  > " inp; [ -n "$inp" ] && V_LOAD="$inp"; echo ""

    read -rp "  🔊 Sahi password - line 1?
  ${DIM}Default: ${V_CORRECT1}${X}
  > " inp; [ -n "$inp" ] && V_CORRECT1="$inp"; echo ""

    read -rp "  🔊 Sahi password - line 2?
  ${DIM}Default: ${V_CORRECT2}${X}
  > " inp; [ -n "$inp" ] && V_CORRECT2="$inp"; echo ""

    read -rp "  🔊 Galat password pe?
  ${DIM}Default: ${V_WRONG}${X}
  > " inp; [ -n "$inp" ] && V_WRONG="$inp"; echo ""

    read -rp "  🔊 3 baar galat hone pe?
  ${DIM}Default: ${V_LOCKED}${X}
  > " inp; [ -n "$inp" ] && V_LOCKED="$inp"; echo ""

    read -rp "  🔊 Forgot password pe?
  ${DIM}Default: ${V_FORGOT}${X}
  > " inp; [ -n "$inp" ] && V_FORGOT="$inp"; echo ""

    read -rp "  🔊 Recovery sahi hone pe?
  ${DIM}Default: ${V_REC_OK}${X}
  > " inp; [ -n "$inp" ] && V_REC_OK="$inp"; echo ""

    read -rp "  🔊 Recovery galat hone pe?
  ${DIM}Default: ${V_REC_FAIL}${X}
  > " inp; [ -n "$inp" ] && V_REC_FAIL="$inp"; echo ""

    read -rp "  🔊 Naya password set hone pe?
  ${DIM}Default: ${V_NEWPASS}${X}
  > " inp; [ -n "$inp" ] && V_NEWPASS="$inp"; echo ""

    # Save config
    cat > "$CONFIG" << CFGEOF
# HCCR MAX Config - by @hccrmax
BANNER_NAME="$(echo "$BANNER_NAME" | sed 's/"/\\"/g')"
SUBTITLE="$(echo "$SUBTITLE" | sed 's/"/\\"/g')"
LOGIN_BTN="$(echo "$LOGIN_BTN" | sed 's/"/\\"/g')"
BY_LINE="by @hccrmax"
PASSWORD="$(echo "$PASSWORD" | sed 's/"/\\"/g')"
RECOVERY_PASS="$(echo "$RECOVERY_PASS" | sed 's/"/\\"/g')"
V_LOAD="$(echo "$V_LOAD" | sed 's/"/\\"/g')"
V_CORRECT1="$(echo "$V_CORRECT1" | sed 's/"/\\"/g')"
V_CORRECT2="$(echo "$V_CORRECT2" | sed 's/"/\\"/g')"
V_WRONG="$(echo "$V_WRONG" | sed 's/"/\\"/g')"
V_LOCKED="$(echo "$V_LOCKED" | sed 's/"/\\"/g')"
V_FORGOT="$(echo "$V_FORGOT" | sed 's/"/\\"/g')"
V_REC_OK="$(echo "$V_REC_OK" | sed 's/"/\\"/g')"
V_REC_FAIL="$(echo "$V_REC_FAIL" | sed 's/"/\\"/g')"
V_NEWPASS="$(echo "$V_NEWPASS" | sed 's/"/\\"/g')"
CFGEOF

    echo ""
    box_top "${G}"
    box_text "✅  Setup Complete! Launching System..." "${G}${B}" "${G}"
    box_bot "${G}"
    echo ""
    sleep 1
}

# ════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════

# Voice warmup background mein
warmup_voice

# Config load
load_config

# First time?
if [ ! -f "$CONFIG" ]; then
    first_setup
    load_config
fi

# Warmup ke liye thoda wait (non-blocking)
sleep 0.8

# Login start
login_page
