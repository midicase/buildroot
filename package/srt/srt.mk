################################################################################
#
# srt
#
################################################################################

# this id is for release 1.4.4
SRT_VERSION = 8b32f3734ff6af7cc7b0fef272591cb80a2d1aae
SRT_SITE = https://github.com/Haivision/srt/tarball/$(SRT_VERSION)
SRT_INSTALL_STAGING = YES
SRT_LICENSE = MPLv2.0
SRT_LICENSE_FILES = LICENSE

SRT_DEPENDENCIES = host-cmake gnutls

SRT_CONF_OPTS += -DUSE_ENCLIB=gnutls

$(eval $(cmake-package))

