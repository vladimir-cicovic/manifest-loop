#!/usr/bin/env bash
# Online mode for Linux and macOS: refreshes the playlist and serves manifest-loop on your
# local network with Python's built-in http.server. Press Ctrl+C to stop the server.
set -euo pipefail

cd "$(dirname "$0")"
PORT="${PORT:-8765}"

bash scripts/generate-playlist.sh

if command -v python3 >/dev/null 2>&1; then
  PY=python3
elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)'; then
  PY=python
else
  echo "Python 3 was not found. Install it (e.g. 'sudo apt install python3' or 'brew install python')."
  echo "You can still use offline mode: just open index.html."
  exit 1
fi

lan_ip() {
  if command -v hostname >/dev/null 2>&1 && hostname -I >/dev/null 2>&1; then
    hostname -I | awk '{print $1}'
  elif command -v ipconfig >/dev/null 2>&1; then
    ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true
  fi
}
IP="$(lan_ip || true)"

echo
echo " ===================================================="
echo "  manifest-loop is running:"
echo
echo "    This computer:   http://localhost:$PORT"
[ -n "$IP" ] && echo "    Phone / TV:      http://$IP:$PORT"
echo
echo "  Your phone must be on the same Wi-Fi network."
echo "  Press Ctrl+C to stop the server."
echo " ===================================================="
echo

# Open the browser if a desktop is available (ignored on headless servers)
( command -v xdg-open >/dev/null 2>&1 && xdg-open "http://localhost:$PORT" >/dev/null 2>&1 ) ||
( command -v open >/dev/null 2>&1 && open "http://localhost:$PORT" >/dev/null 2>&1 ) || true

exec "$PY" -m http.server "$PORT" --bind 0.0.0.0
