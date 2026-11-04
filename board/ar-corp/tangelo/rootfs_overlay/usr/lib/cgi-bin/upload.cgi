#!/bin/bash

UPLOAD_FOLD=/var/www/uploads

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

	# read out file name
	eval `echo $disposition | tr -d '\r' | tr -d '\n' | cut -f4 -d " "`
	cat > /tmp/firmware.tmp

	# remove content-type from multipart/form-data body request 
	for (( i = 0; i <= 5; i++)) 
	do
		sed '$d' /tmp/firmware.tmp > /tmp/cut.tmp
		cp /tmp/cut.tmp /tmp/firmware.tmp
	done
	
	# clear the directory
	rm -rf ${UPLOAD_FOLD}/*
	
	# Extract in the background and tick once a second. The extract is the slow
	# step, and without this the window sits silent long enough to look hung.
	7za x -p$(echo -n tangelo | sha256sum  | awk '{print $1}') /tmp/firmware.tmp -o${UPLOAD_FOLD} > /tmp/extract.log 2>&1 &
	extract_pid=$!
	printf "Extracting"
	while kill -0 ${extract_pid} 2>/dev/null; do
		printf "."
		sleep 1
	done
	wait ${extract_pid}
	extract_rc=$?
	echo
	cat /tmp/extract.log

	if [ ${extract_rc} -eq 0 ]; then
		# stamp upload time now, while the clock is synced; S10updater carries it into update.log
		date +%s > ${UPLOAD_FOLD}/.upload_time
		echo
		echo "Done. Can reboot."
	else
		echo
		echo "Incompatible file."
		exit 406
	fi
fi

exit 0

