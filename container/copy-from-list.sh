#!/bin/sh
# copy-from-list.sh — Copy files according to declarative list
# Usage: copy-from-list.sh <sdk_path>

SDK_PATH="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIST_FILE="$SCRIPT_DIR/../file-list.txt"

while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
        ''|'#'*) continue ;;
    esac

    directive=$(echo "$line" | cut -d' ' -f1)
    src=$(echo "$line" | cut -d' ' -f2)
    dest=$(echo "$line" | cut -d' ' -f3)

    src=$(echo "$src" | sed "s|\$PROJECT_NAME|$PROJECT_NAME|g; s|\$SDK_PATH|$SDK_PATH|g")
    dest=$(echo "$dest" | sed "s|\$PROJECT_NAME|$PROJECT_NAME|g; s|\$SDK_PATH|$SDK_PATH|g")

    case "$directive" in
        -p)
            for src_file in $src; do
                [ -e "$src_file" ] || continue
                cp "$src_file" "$dest" || exit 1
            done
            ;;
        -r)
            [ -d "$src" ] || continue
            cp -R "$src" "$dest" || exit 1
            ;;
        -d)
            [ -f "$src" ] || continue
            mkdir -p "$dest" || exit 1
            cp "$src" "$dest" || exit 1
            ;;
    esac
done < "$LIST_FILE"
