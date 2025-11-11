#!/bin/bash

function usage {
  echo "Usage:"
  echo "  $0 pod     # Run pod_publish.sh with auto version bump"
  echo "  $0 spm     # Run spm_publish.sh with auto version bump"
  echo "  $0 both    # Run both pod and spm with auto version bump"
  exit 1
}

function run_pod_publish {
  echo "🚀 Running pod_publish.sh..."
  ./Scripts/Automation/pod_publish.sh
}

function run_spm_publish {
  echo "🚀 Running spm_publish.sh..."
  ./Scripts/Automation/spm_publish.sh
}

function main {
  if [[ $# -ne 1 ]]; then
    usage
  fi

  local TYPE=$1

  case $TYPE in
    pod)
      run_pod_publish
      ;;
    spm)
      run_spm_publish
      ;;
    both)
      run_pod_publish
      run_spm_publish
      ;;
    *)
      echo "🍎🍎🍎 Error: Unknown type '$TYPE'. Must be 'pod', 'spm', or 'both'."
      usage
      ;;
  esac
}

main "$@"
