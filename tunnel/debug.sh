#!/usr/bin/env bash

set -euo pipefail

# Open an interactive Alpine shell with the Cloudflare tunnel data volume mounted.
#
# Works with either Podman or Docker on macOS and Linux.
# Override defaults if needed:
#   CONTAINER_CLI=docker ./debug.sh
#   TUNNEL_VOLUME_NAME=cloudflare ./debug.sh
#   DEBUG_IMAGE=alpine:3.20 ./debug.sh

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="$(basename "$SCRIPT_DIR")"
DEBUG_IMAGE="${DEBUG_IMAGE:-alpine:3.20}"

if [[ -n "${CONTAINER_CLI:-}" ]]; then
	cli="$CONTAINER_CLI"
elif command -v podman >/dev/null 2>&1; then
	cli="podman"
elif command -v docker >/dev/null 2>&1; then
	cli="docker"
else
	echo "No supported container CLI found. Install podman or docker, or set CONTAINER_CLI." >&2
	exit 1
fi

resolve_volume_name() {
	local candidate

	for candidate in \
		"${TUNNEL_VOLUME_NAME:-}" \
		"${PROJECT_NAME}_cloudflare" \
		"cloudflare"
	do
		[[ -n "$candidate" ]] || continue

		if "$cli" volume inspect "$candidate" >/dev/null 2>&1; then
			printf '%s\n' "$candidate"
			return 0
		fi
	done

	return 1
}

if ! volume_name="$(resolve_volume_name)"; then
	cat >&2 <<EOF
Could not find the tunnel data volume.

Tried:
	- \
		${TUNNEL_VOLUME_NAME:-<unset via TUNNEL_VOLUME_NAME>}
	- ${PROJECT_NAME}_cloudflare
	- cloudflare

Create the volume first with compose, or set TUNNEL_VOLUME_NAME explicitly.
EOF
	exit 1
fi

exec "$cli" run --rm -it \
	-v "${volume_name}:/cdata" \
	"$DEBUG_IMAGE" sh