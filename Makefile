TWEAK_NAME = libdisplaystack

libdisplaystack_OBJC_FILES = Tweak.m
libdisplaystack_FRAMEWORKS = UIKit Foundation CoreFoundation

BUNDLE_NAME = DSPreferences
DSPreferences_OBJC_FILES = Preferences.m
DSPreferences_FRAMEWORKS = UIKit Foundation CoreFoundation CoreGraphics
DSPreferences_PRIVATE_FRAMEWORKS = Preferences SpringBoardServices

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
include framework/makefiles/bundle.mk
