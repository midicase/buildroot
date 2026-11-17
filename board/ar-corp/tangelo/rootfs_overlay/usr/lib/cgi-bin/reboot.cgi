#!/bin/sh
# POST only; a cross-site Origin is refused (CSRF). arsystem (root) does the reboot.

if [ "$REQUEST_METHOD" != "POST" ] || { [ -n "$HTTP_ORIGIN" ] && [ "${HTTP_ORIGIN#*://}" != "$HTTP_HOST" ]; }; then
  logger -t reboot.cgi "refused $REQUEST_METHOD from ${HTTP_ORIGIN:-no origin}"
  echo "Status: 403 Forbidden"
  echo "Content-Type: text/plain"
  echo ""
  echo "Refused"
  exit 0
fi

echo "Content-Type: text/plain"
echo ""
# Client-only nc has no -w; a busybox without timeout still has nc -w.
if command -v timeout >/dev/null 2>&1; then
  send() { timeout 5 nc 127.0.0.1 80; }
else
  send() { nc -w 5 127.0.0.1 80; }
fi
BODY='{"cmd":"reboot"}'
if printf 'PUT /api/system/command HTTP/1.0\r\nHost: localhost\r\nConnection: close\r\nContent-Type: application/json\r\nContent-Length: %d\r\n\r\n%s' "${#BODY}" "$BODY" \
    | send 2>/dev/null | grep -q '"status" *: *"200"'; then
  echo "Reboot... Please wait..."
else
  echo "Reboot failed: the system service did not respond."
fi
exit 0
