ARCHS = armv7 arm64 arm64e
TARGET = iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Shadow

ShadowHooks = $(wildcard hooks/*.x)

Shadow_FILES = $(ShadowHooks) api/Shadow.m api/ShadowXPC.m Tweak.x
Shadow_LIBRARIES = rocketbootstrap
# Shadow_EXTRA_FRAMEWORKS = Cephei
Shadow_PRIVATE_FRAMEWORKS = AppSupport
Shadow_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
