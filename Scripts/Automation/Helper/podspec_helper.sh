#!/bin/bash
# -----------------------------
# Podspec Publishing
# -----------------------------

pod_repo_push() {
    local pod_name="$1"
    local podspec_file="${pod_name}.podspec"

    if pod repo push Specs "$podspec_file" --allow-warnings --verbose; then
        echo "🍏 Successfully pushed ${pod_name} podspec to Specs repo."
    else
        echo "🍎 Failed to push ${pod_name} podspec to Specs repo." >&2
        exit 1
    fi
}

# -----------------------------
# Pre-validation
# -----------------------------
pre_validation_podspecs() {
    local base_pod_name="$1"
    local new_version="$2"

    if [[ "$base_pod_name" =~ "Imp" || "$base_pod_name" =~ "Mock" ]]; then
        echo "🍎 Error: POD_NAME must not contain 'Imp' or 'Mock'." >&2
        exit 1
    fi

    if [[ ! "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "🍎 Error: TAG must be in format x.y.z (e.g., 1.0.0)." >&2
        exit 1
    fi
}
