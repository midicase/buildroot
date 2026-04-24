#!/bin/sh

UPLOAD_FOLD=/var/www/uploads

if [ "$REQUEST_METHOD" = "POST" ]; then
	read boundary
	read disposition
	read ctype
	read junk

	echo "Content-Type: text/plain"
	echo 
	echo "Uploading"
	echo

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
	
	# do the extract
	7za x -p$(echo -n tangelo | sha256sum  | awk '{print $1}') /tmp/firmware.tmp -o${UPLOAD_FOLD} 
	if [ $? -eq 0 ]; then
		echo
		echo "Done. Can reboot."
	else
		echo
		echo "Incompatible file."
		exit 406
	fi
fi

exit 0

