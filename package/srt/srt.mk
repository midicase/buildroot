################################################################################
#
# srt
#
################################################################################

SRT_VERSION = v1.5.4
SRT_SITE = https://github.com/Haivision/srt/tarball/$(SRT_VERSION)
SRT_INSTALL_STAGING = YES
SRT_LICENSE = MPLv2.0
SRT_LICENSE_FILES = LICENSE

SRT_DEPENDENCIES = host-cmake gnutls

SRT_CONF_OPTS += -DUSE_ENCLIB=gnutls -DENABLE_BONDING=ON

$(eval $(cmake-package))

