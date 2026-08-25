################################################################################
#
# svtjpegxs
#
################################################################################

# v0.9.0-59, matching the rumo repo's SVT-JPEG-XS submodule pin. Its head commit is the
# FFmpeg 8.1 MPEG-TS update, which is what the FFmpeg pin above expects.
SVTJPEGXS_VERSION = 8e50180ad909a0bdcdf91b462c64033f0fe3e112
SVTJPEGXS_SITE = $(call github,OpenVisualCloud,SVT-JPEG-XS,$(SVTJPEGXS_VERSION))

SVTJPEGXS_INSTALL_STAGING = YES
SVTJPEGXS_LICENSE = BSD+Patent
SVTJPEGXS_LICENSE_FILES = LICENSE.md

SVTJPEGXS_DEPENDENCIES = host-cmake

SVTJPEGXS_CONF_OPTS += \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=/usr

$(eval $(cmake-package))
