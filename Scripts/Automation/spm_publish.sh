#!/bin/bash

function auto_increase_tag {
  local NEW_TAG_VERSION=$1
  echo "$NEW_TAG_VERSION" > "$SPM_VERSION_FILE"
}

function commit_changes {
  local NEW_TAG_VERSION=$1
  local BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
  
  git add .
  git commit -m "SPM auto release version ${NEW_TAG_VERSION}"
  git push -f origin $BRANCH_NAME
}

function tag_commit {
  local NEW_TAG_VERSION=$1
  local FULL_TAG="${NEW_TAG_VERSION}"
  
  git tag "$FULL_TAG"
  git push -f origin "$FULL_TAG"
}

function pre_validation_tag {
  local NEW_TAG_VERSION=$1
  if [[ ! "$NEW_TAG_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "🍎🍎🍎 Error: TAG must be in the format x.y.z (e.g., 1.0.0)." >&2
    exit 1
  fi
}

function main {
  local ARG_COUNT=$#
  if [ $ARG_COUNT -eq 0 ]; then
    CURRENT_VERSION=$(cat "$SPM_VERSION_FILE")
    IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
    ((VERSION_PARTS[2]++))
    NEW_TAG_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.${VERSION_PARTS[2]}"
    echo "🤖🤖🤖 $BASE_POD_NAME auto-incrementing version from $CURRENT_VERSION to $NEW_TAG_VERSION "
  elif [ $ARG_COUNT -eq 1 ]; then
    NEW_TAG_VERSION=$1
    echo "🤖🤖🤖 manually update version to $NEW_TAG_VERSION"
  else
    echo "🍎🍎🍎 Error: too many arguments. We only support 0 or 1 argument"
    exit 1
  fi
  
  pre_validation_tag $NEW_TAG_VERSION
  auto_increase_tag $NEW_TAG_VERSION
  commit_changes $NEW_TAG_VERSION
  tag_commit $NEW_TAG_VERSION
}

SPM_VERSION_FILE="Scripts/Automation/spm_version.txt"
main "$@"
