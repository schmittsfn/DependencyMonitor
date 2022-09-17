#
# Makefile
# DepdendencyMonitor
#
# Created by Stefan Schmitt on 18/9/22.
#

PRODUCT := DependencyMonitor
OUTDIR := ./Sources/$(PRODUCT).xcframework

clean:
	if [ -d "$(OUTDIR)" ]; then \
		rm -r ${OUTDIR}; \
	fi \

# Creates the xcframework
create-xcframework: clean
	xcodebuild archive \
-scheme $(PRODUCT) \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './.build/$(PRODUCT).framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

	xcodebuild archive \
-scheme $(PRODUCT) \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './.build/$(PRODUCT).framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

	xcodebuild archive \
-scheme $(PRODUCT) \
-configuration Release \
-destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' \
-archivePath './.build/$(PRODUCT).framework-catalyst.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

	xcodebuild -create-xcframework \
-framework './.build/$(PRODUCT).framework-iphonesimulator.xcarchive/Products/Library/Frameworks/$(PRODUCT).framework' \
-framework './.build/$(PRODUCT).framework-iphoneos.xcarchive/Products/Library/Frameworks/$(PRODUCT).framework' \
-framework './.build/$(PRODUCT).framework-catalyst.xcarchive/Products/Library/Frameworks/$(PRODUCT).framework' \
-output './Sources/$(PRODUCT).xcframework'

