#!/usr/bin/env bash
# Compares ExArray between a git revision (default: HEAD) and the working tree with
# Benchee (run time, memory usage and reductions).
#
#   bench/compare.sh                          # HEAD vs working tree
#   bench/compare.sh v1.0.0                   # given revision vs working tree
#   bench/compare.sh v1.0.0 100,10000         # custom array sizes
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
ref="${1:-HEAD}"
sizes="${2:-100,10000,1000000}"
tmp="$(mktemp -d "${TMPDIR:-/tmp}/ex_array_bench.XXXXXX")"
trap 'git -C "$root" worktree remove --force "$tmp/base" >/dev/null 2>&1 || true; rm -rf "$tmp"' EXIT

git -C "$root" worktree add --quiet --detach "$tmp/base" "$ref"

echo "==> Benchmarking $ref" >&2
elixir "$root/bench/run.exs" --path "$tmp/base" --tag "$ref" --sizes "$sizes" \
  --save-dir "$tmp/results" >/dev/null

echo "==> Benchmarking working tree against $ref" >&2
elixir "$root/bench/run.exs" --path "$root" --tag "working tree" --sizes "$sizes" \
  --load-dir "$tmp/results" --save-dir "$tmp/results-new"
