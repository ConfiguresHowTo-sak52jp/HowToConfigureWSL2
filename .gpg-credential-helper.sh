#!/bin/bash

CRED_FILE="$HOME/.password-store/.git-credentials.gpg"
GPG_RECIPIENT="charan.49jp@gmail.com"  # ← GPGのメールまたは鍵ID

case "$1" in
    get)
        if [ -f "$CRED_FILE" ]; then
            gpg --decrypt "$CRED_FILE"
        fi
        ;;
    store)
        TMP=$(mktemp)
        cat > "$TMP"
        gpg --yes --encrypt --recipient "$GPG_RECIPIENT" --output "$CRED_FILE" "$TMP"
        rm -f "$TMP"
        ;;
    erase)
        rm -f "$CRED_FILE"
        ;;
esac
