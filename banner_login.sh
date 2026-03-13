#!/data/data/com.termux/files/usr/bin/bash

# ╔══════════════════════════════════════╗
# ║      HCCR MAX - Banner Login         ║
# ║         by @hccrmax                  ║
# ╚══════════════════════════════════════╝

CONFIG="$HOME/.hccrmax/config.cfg"
SELFIE_COUNT_FILE="$HOME/.hccrmax/.wrongcount"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Voice Function ──────────────────────
speak() {
    local text="$1"
    if command -v termux-tts-speak &>/dev/null; then
        termux-tts-speak -r 0.95 -p 1.1 "$text" &
    elif command -v espeak-ng &>/dev/null; then
        espeak-ng -s 140 -p 55 "$text" &
    fi
}

# ── Load Config ─────────────────────────
load_config() {
    if [ -f "$CONFIG" ]; then
        source "$CONFIG"
    else
        first_time_setup
    fi
}

# ── Draw Banner ──────────────────────────
draw_banner() {
    clear
    echo ""
    # Colorful figlet banner
    if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
        figlet -f banner "$BANNER_NAME" | lolcat
        echo ""
        echo -e "$(echo "━━━━[ $SUBTITLE ]━━━━" | lolcat)"
    else
        echo -e "${RED}${BOLD}"
        echo "  ██╗  ██╗ ██████╗ ██████╗ ██████╗ "
        echo "  ██║  ██║██╔════╝██╔════╝ ██╔══██╗"
        echo "  ███████║██║     ██║      ██████╔╝ "
        echo "  ██╔══██║██║     ██║      ██╔══██╗ "
        echo "  ██║  ██║╚██████╗╚██████╗ ██║  ██║ "
        echo "  ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝"
        echo -e "${RESET}"
        echo -e "${MAGENTA}${BOLD}        ━━━━[ $SUBTITLE ]━━━━${RESET}"
    fi
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}                                      ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  🔐  ${YELLOW}Enter your password below${RESET}         ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}                                      ${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════╝${RESET}"
    echo ""
}

# ── Login Page ───────────────────────────
login_page() {
    draw_banner
    speak "$VOICE_LOAD"

    wrong_count=0
    if [ -f "$SELFIE_COUNT_FILE" ]; then
        wrong_count=$(cat "$SELFIE_COUNT_FILE")
    fi

    while true; do
        # Password input box
        echo -e "${RED}  ┌──────────────────────────────────────┐${RESET}"
        echo -ne "${RED}  │${RESET}  "
        read -s -p "Enter Password... " input_pass
        echo ""
        echo -e "${RED}  └──────────────────────────────────────┘${RESET}"
        echo ""

        if [ "$input_pass" = "$PASSWORD" ]; then
            # ✅ Correct Password
            wrong_count=0
            echo "0" > "$SELFIE_COUNT_FILE"

            echo -e "${GREEN}${BOLD}"
            echo "  ╔══════════════════════════════════════╗"
            echo "  ║       ✅  ACCESS GRANTED  ✅         ║"
            echo "  ╚══════════════════════════════════════╝"
            echo -e "${RESET}"

            speak "$VOICE_CORRECT_1"
            sleep 1
            speak "$VOICE_CORRECT_2"
            sleep 2

            # Load main banner
            load_main_banner
            break

        else
            # ❌ Wrong Password
            wrong_count=$((wrong_count + 1))
            echo "$wrong_count" > "$SELFIE_COUNT_FILE"

            echo -e "${RED}${BOLD}"
            echo "  ╔══════════════════════════════════════╗"
            echo "  ║       ❌  ACCESS DENIED  ❌          ║"
            echo "  ╚══════════════════════════════════════╝"
            echo -e "${RESET}"

            speak "$VOICE_WRONG"

            # 3 baar galat = silent selfie
            if [ "$wrong_count" -ge 3 ]; then
                take_silent_selfie
                wrong_count=0
                echo "0" > "$SELFIE_COUNT_FILE"
            fi

            sleep 1
            draw_banner
        fi

        # Forget Password option
        echo -e "  ${YELLOW}╔══════════════════════════════════════╗${RESET}"
        echo -e "  ${YELLOW}║${RESET}   ${GREEN}[ $LOGIN_BTN_NAME ]${RESET}                           ${YELLOW}║${RESET}"
        echo -e "  ${YELLOW}╚══════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "  ${CYAN}[ Forget Password? ] - type 'forgot'${RESET}"
        echo ""
        echo -e "           ${MAGENTA}by @hccrmax${RESET}"
        echo ""

    done
}

# ── Silent Selfie ────────────────────────
take_silent_selfie() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local save_path="/sdcard/DCIM/Camera/security_$timestamp.jpg"

    # Silent selfie using termux-camera-photo
    if command -v termux-camera-photo &>/dev/null; then
        termux-camera-photo -c 1 "$save_path" 2>/dev/null &
    fi
}

# ── Forget Password ──────────────────────
forgot_password() {
    clear
    echo ""
    echo -e "${YELLOW}${BOLD}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║        🔑  RECOVERY MODE             ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""

    speak "$VOICE_FORGOT"

    echo -e "${CYAN}  ┌──────────────────────────────────────┐${RESET}"
    echo -ne "${CYAN}  │${RESET}  "
    read -s -p "Enter Recovery Password... " rec_input
    echo ""
    echo -e "${CYAN}  └──────────────────────────────────────┘${RESET}"
    echo ""

    if [ "$rec_input" = "$RECOVERY_PASSWORD" ]; then
        speak "$VOICE_RECOVERY_OK"
        echo -e "${GREEN}${BOLD}  ✅ Recovery Successful! Set new password:${RESET}"
        echo ""

        echo -ne "  New Password: "
        read -s new_pass
        echo ""
        echo -ne "  Confirm Password: "
        read -s confirm_pass
        echo ""

        if [ "$new_pass" = "$confirm_pass" ]; then
            # Update config
            sed -i "s/^PASSWORD=.*/PASSWORD=\"$new_pass\"/" "$CONFIG"
            PASSWORD="$new_pass"
            speak "$VOICE_NEWPASS_SET"
            echo -e "${GREEN}  ✅ Password updated successfully!${RESET}"
            sleep 2
            login_page
        else
            echo -e "${RED}  ❌ Passwords don't match! Try again.${RESET}"
            sleep 2
            forgot_password
        fi
    else
        speak "$VOICE_RECOVERY_FAIL"
        echo -e "${RED}  ❌ Wrong Recovery Password!${RESET}"
        sleep 2
        login_page
    fi
}

# ── Main Banner (after login) ─────────────
load_main_banner() {
    clear
    echo ""
    if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
        figlet -f banner "$BANNER_NAME" | lolcat
        echo ""
        echo "━━━━[ $SUBTITLE ]━━━━" | lolcat
    else
        echo -e "${GREEN}${BOLD}  Welcome! Banner Loaded.${RESET}"
    fi
    echo ""
    echo -e "           ${MAGENTA}by @hccrmax${RESET}"
    echo ""
}

# ══════════════════════════════════════════
# FIRST TIME SETUP
# ══════════════════════════════════════════
first_time_setup() {
    clear
    echo ""
    echo -e "${MAGENTA}${BOLD}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║     🚀  HCCR MAX - FIRST TIME SETUP     ║"
    echo "  ║              by @hccrmax                 ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""

    mkdir -p "$HOME/.hccrmax"

    echo -e "${CYAN}━━━━━━━━━━ BANNER SETUP ━━━━━━━━━━${RESET}"
    echo ""

    read -p "  📌 Banner ka naam kya rakhe? (e.g. HCCR MAX): " BANNER_NAME
    read -p "  📌 Subtitle kya rakhe? (e.g. MAX): " SUBTITLE
    read -p "  📌 Login button ka naam? (e.g. LOGIN): " LOGIN_BTN_NAME

    echo ""
    echo -e "${CYAN}━━━━━━━━━━ PASSWORD SETUP ━━━━━━━━━━${RESET}"
    echo ""

    read -s -p "  🔐 Password set karo: " PASSWORD
    echo ""
    read -s -p "  🔐 Recovery password set karo: " RECOVERY_PASSWORD
    echo ""

    echo ""
    echo -e "${CYAN}━━━━━━━━━━ VOICE SETUP ━━━━━━━━━━${RESET}"
    echo -e "${YELLOW}  (Jo likhoge, wahi voice bolegi)${RESET}"
    echo ""

    read -p "  🔊 Login page load hote hi kya bole?
     > " VOICE_LOAD

    read -p "  🔊 Sahi password pe pehli baat? (e.g. Access Granted)
     > " VOICE_CORRECT_1

    read -p "  🔊 Sahi password pe doosri baat? (e.g. Welcome Boss)
     > " VOICE_CORRECT_2

    read -p "  🔊 Galat password pe kya bole?
     > " VOICE_WRONG

    read -p "  🔊 3 baar galat hone pe kya bole? (security alert)
     > " VOICE_SECURITY

    read -p "  🔊 Forget password click pe kya bole?
     > " VOICE_FORGOT

    read -p "  🔊 Recovery password sahi hone pe?
     > " VOICE_RECOVERY_OK

    read -p "  🔊 Recovery password galat hone pe?
     > " VOICE_RECOVERY_FAIL

    read -p "  🔊 Naya password set hone pe?
     > " VOICE_NEWPASS_SET

    # Save config
    cat > "$CONFIG" << EOF
# HCCR MAX Config - by @hccrmax
BANNER_NAME="$BANNER_NAME"
SUBTITLE="$SUBTITLE"
LOGIN_BTN_NAME="$LOGIN_BTN_NAME"
PASSWORD="$PASSWORD"
RECOVERY_PASSWORD="$RECOVERY_PASSWORD"
VOICE_LOAD="$VOICE_LOAD"
VOICE_CORRECT_1="$VOICE_CORRECT_1"
VOICE_CORRECT_2="$VOICE_CORRECT_2"
VOICE_WRONG="$VOICE_WRONG"
VOICE_SECURITY="$VOICE_SECURITY"
VOICE_FORGOT="$VOICE_FORGOT"
VOICE_RECOVERY_OK="$VOICE_RECOVERY_OK"
VOICE_RECOVERY_FAIL="$VOICE_RECOVERY_FAIL"
VOICE_NEWPASS_SET="$VOICE_NEWPASS_SET"
EOF

    echo ""
    echo -e "${GREEN}${BOLD}  ✅ Setup complete! Starting...${RESET}"
    sleep 2

    load_config
    login_page
}

# ── Handle 'forgot' input ─────────────────
handle_input() {
    load_config

    # Check if user typed 'forgot' anywhere
    if [[ "$1" == "forgot" ]]; then
        forgot_password
    else
        login_page
    fi
}

# ── Entry Point ──────────────────────────
load_config
login_page
