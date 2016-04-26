ifeq ($(DEBUG),1)
CONFIG := debug
else
CONFIG := release
endif

all:
	/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/swift build --configuration $(CONFIG)
clean:
	/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/swift build --clean=dist
