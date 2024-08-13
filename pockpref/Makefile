ARCHS = arm64 arm64e
SDK_PATH = $(THEOS)/sdks/iPhoneOS13.7.sdk/
SYSROOT = $(SDK_PATH)
export THEOS_PACKAGE_SCHEME=rootless

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Pockpref

Pockpref_FILES = pockprefRootListController.m
Pockpref_FRAMEWORKS = UIKit
Pockpref_PRIVATE_FRAMEWORKS = Preferences
Pockpref_INSTALL_PATH = /Library/PreferenceBundles
Pockpref_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
