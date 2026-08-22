#!/bin/sh

set -e

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPTS/lib"

# Identify the GitHub repo name based on the default path or origin of our
# sapling or git clone.
REPO="$(identify_github_repo)"
WORKFLOW_ID="fbthrift.yml"

# Runs come back newest first, so the first successful one is the one we want.
# Asking about this workflow specifically beats paging through every run in the
# repo, which gets slower with each night's build.
run_id="$(gh api "repos/${REPO}/actions/workflows/${WORKFLOW_ID}/runs?status=success&per_page=1" \
	     --jq '.workflow_runs[0].id')"

if [ -z "$run_id" ]; then
	echo "No successful ${WORKFLOW_ID} run found in ${REPO}" >&2
	exit 1
fi

echo "Fetching artifacts from ${WORKFLOW_ID} run ${run_id}"
echo "https://github.com/${REPO}/actions/runs/${run_id}/"

tempdir="$(mktemp -d)"
cleanup_tempdir() {
	rm -rf "$tempdir"
}
trap cleanup_tempdir INT TERM EXIT

gh run download "$run_id" --repo "$REPO" --dir "$tempdir"
find "$tempdir" -type f | xargs -I{} cp {} ./artifacts/
