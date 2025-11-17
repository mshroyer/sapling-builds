#!/bin/sh

set -e

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"

# Identify the GitHub repo name based on the default path or origin of our
# sapling or git clone.
REPO="$(identify_github_repo)"
WORKFLOW_ID="fbthrift.yml"

run_id="$(gh api "repos/${REPO}/actions/runs" \
	     --paginate -q \
	     '[ .workflow_runs
	     		     | sort_by(.created_at)
			     | reverse
			     | .[]
			     | select(.name=="fbthrift")
			     | select(.conclusion=="success") ]
			     | .[0]
			     | .id')"

echo "Fetching artifacts from ${WORKFLOW_ID} run ${run_id}"
echo "https://github.com/${REPO}/actions/runs/${run_id}/"

tempdir="$(mktemp -d)"
cleanup_tempdir() {
	rm -rf "$tempdir"
}
trap cleanup_tempdir INT TERM EXIT

gh run download "$run_id" --repo "$REPO" --dir "$tempdir"
find "$tempdir" -type f | xargs -I{} cp {} ./artifacts/
