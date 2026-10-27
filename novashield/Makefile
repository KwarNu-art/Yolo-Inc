THEOS_PACKAGE_SCHEME = rootless
TARGET := iphone:clang:latest:15.0
ARCHS := arm64

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NovaShield

NovaShield_FILES = src/Tweak.x src/NovaHUD.m
NovaShield_CFLAGS = -fobjc-arc -O2 -DNDEBUG -Wno-unused-variable -Wno-deprecated-declarations
NovaShield_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AudioToolbox
NovaShield_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += NovaShieldPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	@mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	@if [ -f layout/DEBIAN/postinst ]; then cp layout/DEBIAN/postinst $(THEOS_STAGING_DIR)/DEBIAN/postinst && chmod 0755 $(THEOS_STAGING_DIR)/DEBIAN/postinst; fi
	@if [ -f layout/DEBIAN/postrm ]; then cp layout/DEBIAN/postrm $(THEOS_STAGING_DIR)/DEBIAN/postrm && chmod 0755 $(THEOS_STAGING_DIR)/DEBIAN/postrm; fi

after-install::
	install.exec "killall -9 SpringBoard || true"
