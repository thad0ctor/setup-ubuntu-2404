#!/usr/bin/env bash
# Merge selected GGUF shards into a single file (runs via Nemo action)
# 2025-07-06  – tested on Ubuntu 24.04 + llama.cpp HEAD
set -euo pipefail

MERGER="/home/rgilbreth/Desktop/llama.cpp/build/bin/llama-gguf-split"

###############################################################################
# 0. Preconditions
###############################################################################
(( $# >= 2 )) || { echo "❌  Select at least two .gguf shards."; exit 1; }

shards=("$@")

# Ensure every file is *.gguf
for f in "${shards[@]}"; do
    [[ ${f,,} == *.gguf ]] || { echo "❌  Not a .gguf file: $f"; exit 1; }
done

# Ensure all shards are in the same directory
dir=$(dirname "${shards[0]}")
for f in "${shards[@]}"; do
    [[ $(dirname "$f") == "$dir" ]] || { echo "❌  Shards must be in one folder."; exit 1; }
done

###############################################################################
# 1. Natural-sort shards (just for human sanity; merge needs only the first)
###############################################################################
IFS=$'\n' shards_sorted=($(printf '%s\n' "${shards[@]}" | sort -V))

###############################################################################
# 2. Derive output filename  (strip  -00001-of-00002   etc., keep original .gguf)
###############################################################################
base="$(basename "${shards_sorted[0]}")"
filename_no_shard="$(echo "$base" | sed -E 's/-[0-9]{5}-of-[0-9]{5}//')"
outfile="$dir/$filename_no_shard"             # already ends in .gguf – no double ext

###############################################################################
# 3. Confirm overwrite if target exists
###############################################################################
if [[ -e "$outfile" ]]; then
    read -rp "⚠️  $outfile exists. Overwrite? [y/N] " yn
    [[ $yn =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

###############################################################################
# 4. Run the merge  (pass ONLY first shard + output)
###############################################################################
echo "🔄  Merging shards into: $outfile"
"$MERGER" --merge "${shards_sorted[0]}" "$outfile"

echo "✅  Merge complete → $(basename "$outfile")"