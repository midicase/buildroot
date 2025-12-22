#!/bin/bash

# This script is called by buildroot config to fixup anything in the rootfs before compressing into final image.

set -e
#set -x

# we should be getting these from the make_release wrapper.  Allows for easier standalone testing.
AR_PRODUCT=${AR_PRODUCT:-tangelo}
AR_HOSTNAME=${AR_HOSTNAME:-Tangelo}

# Generate a build date time.  Jenkins has env RELEASE_ID else generate it.

if [ -z "${RELEASE_ID}" ]; then 
	CURDATETIME=`date +%F_%H-%M-%S`
	# this is for local building outside jenkins to set a default.
	BUILD_TIMESTAMP=${BUILD_TIMESTAMP:-$CURDATETIME}
	RELEASE_ID=${BUILD_TIMESTAMP}
fi
echo "${RELEASE_ID}" > ${TARGET_DIR}/etc/VERSION

cat <<EOF > ${TARGET_DIR}/etc/env.conf
export PRODUCT=${AR_PRODUCT}
export DEFAULT_HOSTNAME=${AR_HOSTNAME}
EOF

