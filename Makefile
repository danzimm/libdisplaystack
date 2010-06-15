TWEAK_NAME = libdisplaystack

libdisplaystack_OBJC_FILES = Tweak.m
libdisplaystack_FRAMEWORKS = UIKit Foundation CoreFoundation

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
