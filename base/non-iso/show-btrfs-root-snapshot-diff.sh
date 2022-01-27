# Example of subvolume IDs
#	$ sudo btrfs subvolume list /
#	> ID 256 gen 930 top level 5 path @
#	> ID 257 gen 931 top level 5 path @home
#	> ID 258 gen 834 top level 5 path @persist
#	> ID 259 gen 846 top level 5 path @nix
#	> ID 260 gen 11 top level 5 path @containercow
#	> ID 261 gen 932 top level 5 path @log
#	> ID 262 gen 13 top level 5 path blank-root
#	> ID 362 gen 391 top level 256 path srv
#	> ID 363 gen 392 top level 256 path var/lib/machines
#	> ID 364 gen 931 top level 256 path tmp
#	$

# Set-up:
trap 'cleanup' EXIT
tmpdir=$(mktemp --tmpdir -d "$(basename "$0").XXXX")

# Ensure this always happens:
cleanup() {
	sudo umount "$tmpdir"
	rmdir "$tmpdir"
}

sudo mount -o subvol=blank-root /dev/mapper/cryptroot "$tmpdir"
OLD_TRANSID="$(sudo btrfs subvolume find-new "$tmpdir" 9999999)"
OLD_TRANSID="${OLD_TRANSID#transid marker was }"

main() {
	# Execute:
	# shellcheck disable=SC2162
	sudo btrfs subvolume find-new / "$OLD_TRANSID" |
	sed '$d' |
	cut -f17- -d' ' |
	sort |
	uniq |
	while read path; do
		path="/$path"
		if [ -L "$path" ]; then
			: # The path is a symbolic link, so is probably handled by NixOS already
		elif [ -d "$path" ]; then
			: # The path is a directory, ignore
		else
			echo "$path"
		fi
	done
}

# Remove persisted paths:
main | grep -v -f <(sudo find /persist/ -type f | sed 's|/persist||')
