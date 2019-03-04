StatusBar
=========

An example of creating a Mac status bar application with
a popover window and some controls. All of the UI is
created programmatically - there are no .xib files or
storyboards.

# Compiling and Running

Clone this repository, open a terminal window, and cd into
the repository directory.

Compile:

    make

A Mac application bundle is created named StatusBar.app. You can either
double-click on the .app file from the Finder, or launch it from the
command line:

    open StatusBar.app

There is some debugging output that is logged to the console. You will
not see this at the terminal window if you launch the .app file as above.
If you would like to see the output, you can run the executable from the
command line like this (do not append the .app suffix):

    ./StatusBar

You can also run the application in the lldb debugger and see the console
output at your terminal:

    lldb StatusBar.app
	(lldb) run


# Author

Jeff Buck


