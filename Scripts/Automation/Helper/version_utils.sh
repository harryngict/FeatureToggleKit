#!/bin/bash
# -----------------------------
# Version Utilities
# -----------------------------

get_current_version() {
    local podspec_file="$1"
    grep -E "^ *spec.version" "$podspec_file" | sed -E 's/.*"(.+)".*/\1/'
}

increment_version() {
    local current_version="$1"
    local major minor patch
    major=$(echo "$current_version" | cut -d. -f1)
    minor=$(echo "$current_version" | cut -d. -f2)
    patch=$(echo "$current_version" | cut -d. -f3)

    patch=$((patch + 1))
    if [ "$patch" -ge 10 ]; then
        patch=0
        minor=$((minor + 1))
    fi
    if [ "$minor" -ge 10 ]; then
        minor=0
        major=$((major + 1))
    fi

    echo "${major}.${minor}.${patch}"
}

update_podspec_version() {
    local pod_name="$1"
    local new_version="$2"
    local podspec_file="${pod_name}.podspec"

    if [ ! -f "$podspec_file" ]; then
        echo "🍎 Error: $podspec_file not found." >&2
        exit 1
    fi

    sed -i "" "s/spec.version      = \".*\"/spec.version      = \"${new_version}\"/" "$podspec_file"
}

