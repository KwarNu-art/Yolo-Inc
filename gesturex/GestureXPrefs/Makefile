TARGET := iphone:clang:latest:15.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GestureXPrefs

GestureXPrefs_FILES = RootListController.m
GestureXPrefs_FRAMEWORKS = UIKit
GestureXPrefs_PRIVATE_FRAMEWORKS = Preferences
GestureXPrefs_INSTALL_PATH = /Library/PreferenceBundles
GestureXPrefs_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-deprecated-declarations -Wno-error

include $(THEOS_MAKE_PATH)/bundle.mk
