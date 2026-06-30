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


AR_INCLUDES="-I${STAGING_DIR}/usr/include -I${STAGING_DIR}/usr/include/libxml2 -I${STAGING_DIR}/usr/include/jsoncpp"


export "AR=aarch64-buildroot-linux-gnu-ar"
export "AS=aarch64-buildroot-linux-gnu-as"
export "LD=aarch64-buildroot-linux-gnu-ld"
export "NM=aarch64-buildroot-linux-gnu-nm"
export "CC=aarch64-buildroot-linux-gnu-gcc"
export "GCC=aarch64-buildroot-linux-gnu-gcc"
export "CPP=aarch64-buildroot-linux-gnu-cpp"
export "CXX=aarch64-buildroot-linux-gnu-g++"
export "FC=aarch64-buildroot-linux-gnu-gfortran"
export "F77=aarch64-buildroot-linux-gnu-gfortran"
export "RANLIB=aarch64-buildroot-linux-gnu-ranlib"
export "READELF=aarch64-buildroot-linux-gnu-readelf"
export "STRIP=aarch64-buildroot-linux-gnu-strip"
export "OBJCOPY=aarch64-buildroot-linux-gnu-objcopy"
export "OBJDUMP=aarch64-buildroot-linux-gnu-objdump"
export "CPPFLAGS=-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64"
export "CFLAGS=-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64  -O3 -g -D_FORTIFY_SOURCE=1 -DUSE_UPDATEENGINE=ON ${AR_INCLUDES}"
export "CXXFLAGS=-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64  -O3 -g -D_FORTIFY_SOURCE=1 ${AR_INCLUDES}"
export "LDFLAGS="
export "PKG_CONFIG=pkg-config"
export "INTLTOOL_PERL=/usr/bin/perl"
export "ARCH=arm64"
export "CROSS_COMPILE=aarch64-buildroot-linux-gnu-"
#export "CONFIGURE_FLAGS=--target=aarch64-buildroot-linux-gnu --host=aarch64-buildroot-linux-gnu --build=x86_64-pc-linux-gnu --prefix=/usr --exec-prefix=/usr --sysconfdir=/etc --localstatedir=/var --program-prefix="
export "CONFIGURE_FLAGS=--target=aarch64-buildroot-linux-gnu --host=aarch64-buildroot-linux-gnu --prefix=/usr --exec-prefix=/usr --sysconfdir=/etc --localstatedir=/var --program-prefix="
export "PATH=$HOST_DIR/bin:$HOST_DIR/sbin:$PATH"



if [ ! -d ${BUILD_DIR}/te0820 ]; then
    git clone -b main --single-branch git@github.com:midicase/te0820.git ${BUILD_DIR}/te0820 
else
	pushd ${BUILD_DIR}/te0820
	git pull
	popd
fi

pushd ${BUILD_DIR}/te0820/apps/system

libtoolize --automake
aclocal
autoconf
autoheader
automake --add-missing -cf --foreign
./configure ${CONFIGURE_FLAGS}
make -j$((`nproc`+1))
install -D -m 0755 arsystem ${TARGET_DIR}/usr/sbin/arsystem

popd

pushd ${BUILD_DIR}/te0820/apps/tangelo

libtoolize --automake
aclocal
autoconf
autoheader
automake --add-missing -cf --foreign
./configure ${CONFIGURE_FLAGS}
make -j$((`nproc`+1))
install -D -m 0755 tangelo ${TARGET_DIR}/usr/sbin/tangelo

pushd web_root

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm use --lts
npm install --legacy-peer-deps
npm run build
cp -a dist/* ${TARGET_DIR}/var/www/

popd
popd

exit


