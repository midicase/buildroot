################################################################################
#
# makeself
#
################################################################################

MAKESELF_VERSION = df82acb98c0722eed18f547f463a632af0478269
MAKESELF_SITE = https://github.com/megastep/makeself
MAKESELF_SITE_METHOD = git
MAKESELF_LICENSE = LGPL
MAKESELF_LICENSE_FILES = COPYING

define HOST_MAKESELF_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/makeself.sh $(HOST_DIR)/usr/bin/makeself.sh
	$(INSTALL) -D -m 0755 $(@D)/makeself-header.sh $(HOST_DIR)/usr/bin/makeself-header.sh
endef

$(eval $(host-generic-package))
