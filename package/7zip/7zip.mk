################################################################################
#
# 7zip
#
################################################################################

7ZIP_VERSION = 26.06
7ZIP_SOURCE = 7z$(subst .,,$(7ZIP_VERSION))-src.tar.xz
7ZIP_SITE = https://github.com/ip7z/7zip/releases/download/$(7ZIP_VERSION)
# The tarball has no top-level directory.
7ZIP_STRIP_COMPONENTS = 0
7ZIP_LICENSE = LGPL-2.1+ with unRAR restriction, BSD-3-Clause (LZFSE, Zstd), BSD-2-Clause (xxHash)
7ZIP_LICENSE_FILES = DOC/License.txt DOC/copying.txt DOC/unRarLicense.txt
7ZIP_CPE_ID_VENDOR = 7-zip
7ZIP_CPE_ID_PRODUCT = 7-zip

# Plain C/C++ build, no assembler. Our flags go in through the
# *FLAGS_BASE2 hooks. Drop -Werror (new toolchains add warnings) and -s
# (Buildroot strips).
7ZIP_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CXX="$(TARGET_CXX)" \
	CFLAGS_BASE2="$(TARGET_CFLAGS)" \
	CXXFLAGS_BASE2="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	CFLAGS_WARN_WALL="-Wall" \
	LFLAGS_STRIP= \
	O=b

define 7ZIP_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(7ZIP_MAKE_OPTS) \
		-C $(@D)/CPP/7zip/Bundles/Alone2 -f ../../cmpl_gcc.mak
endef

define 7ZIP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/CPP/7zip/Bundles/Alone2/b/7zz \
		$(TARGET_DIR)/usr/bin/7zz
endef

$(eval $(generic-package))
