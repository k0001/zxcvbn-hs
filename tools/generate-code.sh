#! /usr/bin/env nix-shell
#! nix-shell -i bash shell.nix
# shellcheck shell=bash

set -e
set -u

top=$(realpath "$(dirname "$0")/..")
data=$(realpath "$top/data")
src=$(realpath "$top/src/Text/Password/Strength/Generated")

echo "==> Adjacency.hs"
zxcvbn-tools adjacency \
  "$data/keyboards/en-US/qwerty.txt" \
  "$data/keyboards/en-US/numpad.txt" \
  > "$src/Adjacency.hs.new"

mv "$src/Adjacency.hs.new" "$src/Adjacency.hs"

echo "==> Frequency.hs"
zxcvbn-tools frequency \
  "$data/passwords/xato.txt:30000"                       \
  "$data/dictionaries/en-US/us_tv_and_film.txt:30000"    \
  "$data/dictionaries/en-US/english_wikipedia.txt:30000" \
  "$data/dictionaries/en-US/surnames.txt:10000"          \
  "$data/dictionaries/en-US/male_names.txt"              \
  "$data/dictionaries/en-US/female_names.txt"            \
  > "$src/Frequency.hs.new"

mv "$src/Frequency.hs.new" "$src/Frequency.hs"

# Local Variables:
#   mode: sh
#   sh-shell: bash
# End:
