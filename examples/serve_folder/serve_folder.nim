import std/os

import webui

proc main = 
  # Create a new window
  let window = newWindow()

  # Bind an HTML element ID with a C function
  window.bind("SwitchToSecondPage") do (e: Event):
    # This function gets called every time 
    # the user clicks on "SwitchToSecondPage" button

    e.window.open("second.html")

  window.bind("Exit") do (_: Event):
    webui.exit()

  # The root path. Leave it empty to let the WebUI
  # automatically select the current working folder
  let rootPath = ""

  # Create a new web server using WebUI
  let link = newServer(window, rootPath)

  # Show the window using the generated URL
  if not window.open(link, BrowserChrome):  # Run the window on Chrome
    window.open(link, BrowserAny)           # If not, run on any other installed web browser

  # Wait until all windows get closed
  wait()

# set current dir to current source path so you
# don't have to look for the example/folder
setCurrentDir(currentSourcePath().parentDir())

main()