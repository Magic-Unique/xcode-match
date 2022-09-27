
.PHONY:xcode-match

TMP_FILE := ./.makebuild/

xcode-match: 
	rm -rf $(TMP_FILE) 
	rm -f xcode-match
	pod install
	xcodebuild -workspace "XcodeMatch.xcworkspace" -scheme "XcodeMatch (Release)" -derivedDataPath .makebuild build
	cp -rf ".makebuild/Build/Products/Release/XcodeMatch" ./xcode-match
	rm -rf $(TMP_FILE)
	
install:
	make xcode-match
	install ./xcode-match /usr/local/bin/xcode-match

clean:
	rm -rf xcode-match $(TMP_FILE)
