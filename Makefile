CXX = clang
COPTS =-g -std=c11 -Wall -Wextra -Wno-null-dereference
#COPTS = -O3 -std=c11 -Wall -Wextra -Wno-null-dereference
CFLAGS = $(COPTS)

default:	StatusBar

all:	StatusBar

StatusBar: statusbar.m

StatusBar:	statusbar.m
	$(CXX) $(COPTS) -framework Cocoa -o $@ $^
	rm -rf ./StatusBar.app
	mkdir -p ./StatusBar.app/Contents/MacOS
	mkdir -p ./StatusBar.app/Contents/Resources
	cp StatusBar StatusBar.app/Contents/MacOS/StatusBar
	cp StatusBar.info.plist StatusBar.app/Contents/Info.plist
	#cp StatusBar\@2x.png ./StatusBar.app/Contents/Resources
	cp StatusBar.pdf ./StatusBar.app/Contents/Resources

clean:
	rm -rf StatusBar StatusBar.app *.o *.dSYM

