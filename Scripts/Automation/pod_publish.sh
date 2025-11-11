#!/bin/bash
set -euo pipefail

# -----------------------------
# Imports
# -----------------------------
source Scripts/Automation/Helper/version_utils.sh
source Scripts/Automation/Helper/git_helper.sh
source Scripts/Automation/Helper/podspec_helper.sh

# -----------------------------
# Deploy Pod Library
# -----------------------------

prepare_and_deploy_pod() {
    local base_pod_name="$1"
    local new_version

    if [ "$ARG_COUNT" -eq 0 ]; then
        local current_version
        current_version=$(get_current_version "${base_pod_name}.podspec")
        new_version=$(increment_version "$current_version")
        echo "🤖 Auto-incrementing $base_pod_name version from $current_version to $new_version"
    else
        new_version="$1"
        echo "🤖 Manually updating $base_pod_name version to $new_version"
    fi

    pre_validation_podspecs "$base_pod_name" "$new_version"
    release_pod_library "$base_pod_name" "$new_version"
}

release_pod_library() {
    local base_pod_name="$1"
    local new_version="$2"
    local pod_names=("$base_pod_name")

    # Include Mock/Imp variants if exist
    [ -f "${base_pod_name}Mock.podspec" ] && pod_names+=("${base_pod_name}Mock")
    [ -f "${base_pod_name}Imp.podspec" ] && pod_names+=("${base_pod_name}Imp")

    for pod_name in "${pod_names[@]}"; do
        update_podspec_version "$pod_name" "$new_version"
        commit_changes "$pod_name" "$new_version"
        tag_commit "$pod_name" "$new_version"
        pod_repo_push "$pod_name"
        pod repo update
    done
}

# -----------------------------
# Main
# -----------------------------
main() {
    ARG_COUNT=$#
    local pod_deploy_file="$(dirname "$0")/pod_deploy_name.txt"

    if [ ! -f "$pod_deploy_file" ]; then
        echo "File not found: $pod_deploy_file" >&2
        exit 1
    fi

    while IFS= read -r library_name || [[ -n "$library_name" ]]; do
        [[ -n "$library_name" ]] && prepare_and_deploy_pod "$library_name"
    done < "$pod_deploy_file"
}

# -----------------------------
# Run
# -----------------------------
main "$@"
exit 0
