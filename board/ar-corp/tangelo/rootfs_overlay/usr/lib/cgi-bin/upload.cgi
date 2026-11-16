#!/bin/bash

UPLOAD_FOLD=/var/www/uploads

# A cross-site Origin is refused (CSRF).
if [ -n "$HTTP_ORIGIN" ] && [ "${HTTP_ORIGIN#*://}" != "$HTTP_HOST" ]; then
	logger -t upload.cgi "refused origin $HTTP_ORIGIN"
	echo "Status: 403 Forbidden"
	echo "Content-Type: text/plain"
	echo
	echo "Refused"
	exit 0
fi

if [ "$REQUEST_METHOD" = "POST" ]; then
	read boundary
	read disposition
	read ctype
	read junk

	echo "Content-Type: text/plain"
	echo
	# A browser holds back a streamed text/plain document until roughly 1KB has
	# arrived, which would swallow the progress ticks below. Pad past that
	# threshold so output renders as it is produced.
	printf '%1024s' ''
	echo
	echo "Uploading"
	echo
	# No ticks during the transfer: lighttpd will not send response bytes while
	# it is still reading the request body, so they would all land at once when
	# the upload finishes. The extract below is streamed and can tick.

	# The client filename is not used: it is attacker-controlled.
	FW_TMP=$(mktemp /tmp/firmware.XXXXXX) || exit 1
	CUT_TMP=$(mktemp /tmp/cut.XXXXXX) || exit 1
	EXTRACT_LOG=$(mktemp /tmp/extract.XXXXXX) || exit 1
	trap 'rm -f "$FW_TMP" "$CUT_TMP" "$EXTRACT_LOG"' EXIT
	cat > "$FW_TMP"

	# remove content-type from multipart/form-data body request 
	for (( i = 0; i <= 5; i++)) 
	do
		sed '$d' "$FW_TMP" > "$CUT_TMP"
		cp "$CUT_TMP" "$FW_TMP"
	done
	
	# Release archives are always password-encrypted (make_release.sh). Refuse
	# one with any unencrypted file, before the staging folder is touched.
	# Directories are never encrypted: zip marks them "Folder = +", 7z only
	# by a leading D in "Attributes".
	if ! 7zz l -slt -p$(echo -n tangelo | sha256sum  | awk '{print $1}') "$FW_TMP" 2>/dev/null | awk '
		/^----------/ { body = 1; next }
		body && /^Path = / { n++; folder = 0 }
		body && (/^Folder = \+/ || /^Attributes = D/) { folder = 1 }
		body && /^Encrypted = / { if (!folder && $3 != "+") bad = 1 }
		END { exit (n == 0 || bad) }'; then
		logger -t upload.cgi "refused archive without password encryption"
		echo "Incompatible file: not an encrypted release archive."
		exit 406
	fi

	# clear the directory
	rm -rf ${UPLOAD_FOLD}/*
	
	# Extract in the background and tick once a second. The extract is the slow
	# step, and without this the window sits silent long enough to look hung.
	7zz x -p$(echo -n tangelo | sha256sum  | awk '{print $1}') "$FW_TMP" -o${UPLOAD_FOLD} > "$EXTRACT_LOG" 2>&1 &
	extract_pid=$!
	printf "Extracting"
	while kill -0 ${extract_pid} 2>/dev/null; do
		printf "."
		sleep 1
	done
	wait ${extract_pid}
	extract_rc=$?
	echo
	cat "$EXTRACT_LOG"

	if [ ${extract_rc} -eq 0 ]; then
		# stamp upload time now, while the clock is synced; S10updater carries it into update.log
		date +%s > ${UPLOAD_FOLD}/.upload_time
		echo
		echo "Done. Can reboot."
	else
		# 7zz leaves partial files behind (e.g. on a wrong password); S10updater must not see them.
		rm -rf ${UPLOAD_FOLD}/*
		echo
		echo "Incompatible file."
		exit 406
	fi
fi

exit 0

