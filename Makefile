ARCHS = arm64 arm64e
SDK_PATH = $(THEOS)/sdks/iPhoneOS13.7.sdk/
SYSROOT = $(SDK_PATH)
export DEBUG = 0
export FINALPACKAGE = 1
export THEOS_DEVICE_IP = localhost
# export THEOS_DEVICE_USER = mobile
export THEOS_DEVICE_PORT=2222
export THEOS_PACKAGE_SCHEME=rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Pock

Pock_FILES = Pock.xm
Pock_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += pockpref
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
