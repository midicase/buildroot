#!/bin/sh
# Config fragment for conf-enabled/tls.conf. Runs as root at start and as
# www-data on a graceful restart, so it tests what that user can read.
# HTTPS only when the key pair is readable. Plain HTTP is off by default
# (loopback only, for reboot.cgi) unless $D/http-on exists, and only while
# HTTPS is on, so the unit is never unreachable.
# A lighttpd built without mod_gnutls would refuse the whole config.
D=/var/lib/lighttpd
if [ -r $D/tls/key.pem ] && [ -r $D/tls/cert.pem ] && [ -e /usr/lib/lighttpd/mod_gnutls.so ]; then
	cat /etc/lighttpd/tls.inc
	[ -e $D/http-on ] || echo 'server.bind := "127.0.0.1"'
fi
exit 0
