#!/bin/bash
# integrity-check - Log file integrity verification with real-time alerts
# Features:
#   - Recursive scanning
#   - Skips unreadable files
#   - Reports modified files
#   - Real-time monitoring with alerts
#   - SHA-256 hashes stored in ~/.log_hashes

HASH_STORE="$HOME/.log_hashes"
SLEEP_INTERVAL=10  # seconds between checks in watch mode

# Initialize hashes
init_hashes() {
    local target="$1"
    mkdir -p "$HASH_STORE"
    echo "Initializing hashes for $target..."

    find "$target" -type f 2>/dev/null | while read -r file; do
        if [[ -r "$file" ]]; then
            sha256sum "$file" > "$HASH_STORE/$(echo "$file" | sed 's|/|_|g').sha256"
        else
            echo "Skipping unreadable file: $file"
        fi
    done

    echo "Hashes stored successfully."
}

# Check hashes once
check_hashes() {
    local target="$1"
    local modified_files=()

    find "$target" -type f 2>/dev/null | while read -r file; do
        if [[ -r "$file" ]]; then
            local hash_file="$HASH_STORE/$(echo "$file" | sed 's|/|_|g').sha256"
            if [[ -f "$hash_file" ]]; then
                local old_hash=$(cut -d ' ' -f1 "$hash_file")
                local new_hash=$(sha256sum "$file" | cut -d ' ' -f1)
                if [[ "$old_hash" != "$new_hash" ]]; then
                    modified_files+=("$file")
                fi
            else
                echo "No hash stored for $file. Use init first."
            fi
        fi
    done

    if [[ ${#modified_files[@]} -eq 0 ]]; then
        echo "All files are unmodified."
    else
        echo "Modified files detected:"
        for f in "${modified_files[@]}"; do
            echo " - $f"
        done
    fi
}

# Update hash for a single file
update_hash() {
    local file="$1"
    if [[ -f "$file" && -r "$file" ]]; then
        mkdir -p "$HASH_STORE"
        sha256sum "$file" > "$HASH_STORE/$(echo "$file" | sed 's|/|_|g').sha256"
        echo "Hash updated successfully for $file."
    else
        echo "Error: $file not found or unreadable."
        exit 1
    fi
}

# Watch a directory for changes
watch_directory() {
    local target="$1"
    echo "Watching $target for file changes every $SLEEP_INTERVAL seconds..."
    while true; do
        modified_files=()
        find "$target" -type f 2>/dev/null | while read -r file; do
            if [[ -r "$file" ]]; then
                local hash_file="$HASH_STORE/$(echo "$file" | sed 's|/|_|g').sha256"
                if [[ -f "$hash_file" ]]; then
                    local old_hash=$(cut -d ' ' -f1 "$hash_file")
                    local new_hash=$(sha256sum "$file" | cut -d ' ' -f1)
                    if [[ "$old_hash" != "$new_hash" ]]; then
                        echo "[ALERT] File modified: $file"
                    fi
                fi
            fi
        done
        sleep "$SLEEP_INTERVAL"
    done
}

# Main
case "$1" in
    init)
        [[ -z "$2" ]] && { echo "Usage: $0 init <file_or_directory>"; exit 1; }
        init_hashes "$2"
        ;;
    check|-check)
        [[ -z "$2" ]] && { echo "Usage: $0 check <file_or_directory>"; exit 1; }
        check_hashes "$2"
        ;;
    update)
        [[ -z "$2" ]] && { echo "Usage: $0 update <file>"; exit 1; }
        update_hash "$2"
        ;;
    watch)
        [[ -z "$2" ]] && { echo "Usage: $0 watch <directory>"; exit 1; }
        watch_directory "$2"
        ;;
    *)
        echo "Usage: $0 {init|check|update|watch} <file_or_directory>"
        exit 1
        ;;
esac
