################################################################################
#
# svtjpegxs
#
################################################################################

SVTJPEGXS_VERSION = 0.9.0
#SVTJPEGXS_SITE = https://github.com/OpenVisualCloud/SVT-JPEG-XS/releases/download/$(SVTJPEGXS_VERSION)
SVTJPEGXS_SITE = $(call github,OpenVisualCloud,SVT-JPEG-XS,v$(SVTJPEGXS_VERSION))

SVTJPEGXS_INSTALL_STAGING = YES
SVTJPEGXS_LICENSE = BSD+Patent
SVTJPEGXS_LICENSE_FILES = LICENSE.md

SVTJPEGXS_DEPENDENCIES = host-cmake

SVTJPEGXS_CONF_OPTS += \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=/usr

#define SVTJPEGXS_BUILD_CMDS
#	(cd $(@D)/Build/linux; \
#		./build.sh release prefix=/usr)
#endef

#define SVTJPEGXS_INSTALL_PKGFILE
#	$(INSTALL) -D -m 0644 $(@D)/Build/linux/Release/SvtJpegxs.pc $(STAGING_DIR)/usr/lib/pkgconfig/
#endef

#SVTJPEGXS_POST_INSTALL_STAGING_HOOKS += SVTJPEGXS_INSTALL_PKGFILE

$(eval $(cmake-package))
