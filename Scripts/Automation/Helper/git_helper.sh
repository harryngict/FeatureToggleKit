#!/bin/bash
# -----------------------------
# Git Helpers
# -----------------------------
commit_changes() {
    local pod_name="$1"
    local new_version="$2"
    local branch_name
    branch_name=$(git rev-parse --abbrev-ref HEAD)

    git add .
    git commit -m "Auto update ${pod_name} and related pods to version ${new_version}"
    git push -f origin "$branch_name"
}

tag_commit() {
    local pod_name="$1"
    local new_version="$2"
    local full_tag="${pod_name}-${new_version}"

    git tag "$full_tag"
    git push -f origin "$full_tag"
}
