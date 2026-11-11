#!/usr/bin/env bash
# Safe authentication injector for Woodpecker private Git clone steps
set -euo pipefail

if [ -z "${CI_NETRC_PASSWORD:-}" ] && [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "::error::No CI clone credentials available. Failing closed before unauthenticated clone." >&2
    exit 128
fi

AUTH_TOKEN="${CI_NETRC_PASSWORD:-${GITHUB_TOKEN}}"
AUTH_MACHINE="${CI_NETRC_MACHINE:-github.com}"
AUTH_LOGIN="${CI_NETRC_USERNAME:-x-access-token}"

NETRC_FILE="${HOME}/.netrc"
mkdir -p "${HOME}"
chmod 700 "${HOME}"

# Atomically write netrc with strict permissions (0600) to prevent log leakage
cat <<EOF > "${NETRC_FILE}"
machine ${AUTH_MACHINE}
login ${AUTH_LOGIN}
password ${AUTH_TOKEN}
EOF
chmod 600 "${NETRC_FILE}"

echo "Successfully configured authenticated Git credentials for ${AUTH_MACHINE} (exit 0)"
exit 0
