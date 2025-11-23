################################################################################
#
# svtjpegxs
#
################################################################################

SVTJPEGXS_VERSION = 0.9.0
SVTJPEGXS_SITE = $(call github,OpenVisualCloud,SVT-JPEG-XS,v$(SVTJPEGXS_VERSION))

SVTJPEGXS_INSTALL_STAGING = YES
SVTJPEGXS_LICENSE = BSD+Patent
SVTJPEGXS_LICENSE_FILES = LICENSE.md

SVTJPEGXS_DEPENDENCIES = host-cmake

SVTJPEGXS_CONF_OPTS += \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=/usr

$(eval $(cmake-package))
