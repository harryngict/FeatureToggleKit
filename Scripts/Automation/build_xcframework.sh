#!/bin/bash
set -euo pipefail

source Scripts/Automation/Helper/version_utils.sh
source Scripts/Automation/Helper/git_helper.sh
source Scripts/Automation/Helper/podspec_helper.sh


# ----------------------------
# Config
# ----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="build"
XCFRAMEWORK_DIR="Frameworks"
LOCAL_XCFRAMEWORKS_DIR="Scripts/Frameworks"
WORKSPACE="Example.xcworkspace"

mkdir -p "$BUILD_DIR"
mkdir -p "$XCFRAMEWORK_DIR"
mkdir -p "$LOCAL_XCFRAMEWORKS_DIR"

# ----------------------------
# Functions
# ----------------------------
build_xcframework() {
    local LIB_NAME="$1"
    local VERSION="$2"
    local ARCHIVE_DEVICE="$BUILD_DIR/${LIB_NAME}-${VERSION}-ios.xcarchive"
    local ARCHIVE_SIM="$BUILD_DIR/${LIB_NAME}-${VERSION}-sim.xcarchive"
    local XCFRAMEWORK="$XCFRAMEWORK_DIR/${LIB_NAME}-${VERSION}.xcframework"
    local ZIP_NAME="${LIB_NAME}-${VERSION}.xcframework.zip"

    rm -rf "$ARCHIVE_DEVICE" "$ARCHIVE_SIM" "$XCFRAMEWORK"

    echo "🔨 Building $LIB_NAME ($VERSION) XCFramework..."

    xcodebuild archive \
        -workspace "$WORKSPACE" \
        -scheme "$LIB_NAME" \
        -sdk iphoneos \
        -archivePath "$ARCHIVE_DEVICE" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty

    xcodebuild archive \
        -workspace "$WORKSPACE" \
        -scheme "$LIB_NAME" \
        -sdk iphonesimulator \
        -archivePath "$ARCHIVE_SIM" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty

    xcodebuild -create-xcframework \
        -framework "$ARCHIVE_DEVICE/Products/Library/Frameworks/${LIB_NAME}.framework" \
        -framework "$ARCHIVE_SIM/Products/Library/Frameworks/${LIB_NAME}.framework" \
        -output "$XCFRAMEWORK"

    echo "✅ Created XCFramework: $XCFRAMEWORK"
}

update_podspec_source() {
    local LIB_NAME="$1"
    local VERSION="$2"
    local PODSPEC_FILE="${LIB_NAME}.podspec"

    if [ ! -f "$PODSPEC_FILE" ]; then
        echo "⚠️ Podspec $PODSPEC_FILE not found. Skipping update."
        return
    fi

    if grep -q "spec.vendored_frameworks" "$PODSPEC_FILE"; then
        sed -i "" "s|spec.vendored_frameworks.*|spec.vendored_frameworks = \"Frameworks/${LIB_NAME}-${VERSION}.xcframework\"|" "$PODSPEC_FILE"
    else
        sed -i "" "/spec.source/ a\\
  spec.vendored_frameworks = \"Frameworks/${LIB_NAME}-${VERSION}.xcframework\"
" "$PODSPEC_FILE"
    fi

    echo "✅ Updated vendored_frameworks path to Frameworks/${LIB_NAME}-${VERSION}.xcframework in $PODSPEC_FILE"
}

cleanup_xcframeworks() {
    echo "🧹 Cleaning up XCFramework directories..."
    rm -rf "$BUILD_DIR"/*
    rm -rf "$LOCAL_XCFRAMEWORKS_DIR"/*
    echo "✅ Cleanup complete"
}

# ----------------------------
# Main
# ----------------------------

deploy_xcframework() {
    local base_pod_name="$1"
    local new_version
    local pod_names=("$base_pod_name")

    # Include Mock/Imp variants if they exist
    [ -f "${base_pod_name}Mock.podspec" ] && pod_names+=("${base_pod_name}Mock")
    [ -f "${base_pod_name}Imp.podspec" ] && pod_names+=("${base_pod_name}Imp")

    if [ "$ARG_COUNT" -eq 0 ]; then
        local current_version
        current_version=$(get_current_version "${base_pod_name}.podspec")
        new_version=$(increment_version "$current_version")
        echo "🤖 Auto-incrementing ${base_pod_name} version from $current_version to $new_version"
    else
        new_version="$1"
        echo "🤖 Manually updating ${base_pod_name} version to $new_version"
    fi

    for pod_name in "${pod_names[@]}"; do
        update_podspec_version "$base_pod_name" "$new_version"
        build_xcframework "$base_pod_name" "$new_version"
        update_podspec_source "$base_pod_name" "$new_version"
        cleanup_xcframeworks
        
        commit_changes "$pod_name" "$new_version"
        tag_commit "$pod_name" "$new_version"
        pod_repo_push "$pod_name"
        pod repo update
    done
}

main() {
    ARG_COUNT=$#
    local pod_deploy_file="$(dirname "$0")/pod_deploy_name.txt"

    if [ ! -f "$pod_deploy_file" ]; then
        echo "File not found: $pod_deploy_file" >&2
        exit 1
    fi

    while IFS= read -r library_name || [[ -n "$library_name" ]]; do
        [[ -n "$library_name" ]] && deploy_xcframework "$library_name"
    done < "$pod_deploy_file"
}

# ----------------------------
# Run
# ----------------------------
main "$@"
exit 0
