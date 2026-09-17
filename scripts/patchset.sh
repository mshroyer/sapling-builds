#!/bin/sh

# Maintain patchsets with Sapling
#
# Helps maintain a patchset on top of a Sapling repository by either importing
# a directory of patches into a private branch, or conversely exporting a
# private branch into a directory of patches.  This makes it easier to work
# with and keep up-to-date my patches to sapling itself.
#
# Assumes a Sapling repository in the present working directory if the -r flag
# is not given.
#
# Usage:
#     patchset.sh [-r $repo_dir] -p $patch_dir (import|export)

set -e

show_usage() {
	cat <<'EOF'
patchset.sh - Convert Sapling branches to/from patch directories

Usage:
    patchset.sh [-r $repo_dir] -p $patch_dir (import|export)
    patchset.sh -h
EOF
}

import_patches() {
	repo_dir="$1"
	patch_dir="$2"
	cd "$repo_dir"

	for p in "$patch_dir"/*.patch; do
		echo "patch: $p" >&2

		if [ ! -f "$p" ]; then
			continue
		fi

		filename="$(basename "$p")"
		message="${filename%.patch}"
		patch -p1 <"$p"
		sl addremove
		sl commit -m "$message"
	done
}

export_patches() {
	repo_dir="$1"
	patch_dir="$2"
	cd "$repo_dir"

	# Sanity check the current stack before exporting as patches.  The
	# commits should be stacked in alphabetical order from the bottom up
	# so that the build script will attempt to re-apply the patches in the
	# correct order.
	descs="$(sl log -r 'branch(.) and not public()' --template "{desc}\n")"
	if [ "$(echo "$descs" | wc -l)" -gt 100 ]; then
		echo "Unexpectedly large number of patches, aborting" >&2
		exit 1
	fi
	sorted_descs="$(echo "$descs" | sort)"
	if [ "$descs" != "$sorted_descs" ]; then
		echo "Stack is not in alphabetical order:\n$descs" >&2
		exit 1
	fi

	rm -f "$patch_dir"/*.patch

	hashes="$(sl log -r 'ancestors(.) and not public()' --template "{node}\n")"
	for hash in $hashes; do
		desc="$(sl log -r "$hash" --template "{desc}\n")"
		echo "Exporting: $desc" >&2
		sl diff -c $hash >"$patch_dir/$desc.patch"
	done
}

patch_flag=
repo_flag="$(pwd)"
help_flag=
while getopts r:p:h flag
do
	case "$flag" in
		r)
			repo_flag="$OPTARG"
			;;
		
		p)
			patch_flag="$OPTARG"
			;;

		h)
			help_flag=1
			;;

		*)
			echo "Unknown flag: $flag" >&2
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))

if [ -n "$help_flag" ]; then
	show_usage
	exit 0
fi

if [ -z "$patch_flag" ]; then
	show_usage
	exit 1
fi

command="$1"
case "$command" in
	'import')
		import_patches "$repo_flag" "$patch_flag"
		;;

	'export')
		export_patches "$repo_flag" "$patch_flag"
		;;

	*)
		show_usage
		exit 1
esac
