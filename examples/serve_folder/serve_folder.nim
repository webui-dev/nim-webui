import std/os

import webui

var
  window: Window
  window2: Window

proc exitApp(_: Event) = 
  exit()

proc main = 
  # Create new windows

  window = newWindow(1)
  window2 = newWindow(2)
  
  window.bind("SwitchToSecondPage") do (e: Event):
    # This function gets called every
    # time the user clicks on "SwitchToSecondPage"

    # Switch to `./second.html` in the same opened window.

    e.window.show("second.html")

  window.bind("OpenNewWindow") do (e: Event):
    # This function gets called every
    # time the user clicks on "OpenNewWindow"

    # Show a new window, and navigate to `/second.html`
    # if it's already open, then switch in the same window

    window2.show("second.html")

  window.bind("") do (e: Event):
    # This function gets called every time
    # there is an event

    case e.eventType:
      of EventsConnected:
        echo "Connected"
      of EventsDisconnected:
        echo "Disconnected"
      of EventsMouseClick:
        echo "Click"
      of EventsNavigation:
        echo "Starting navigation to: ", e.data    
      else:
        discard

  window.bind("Exit", exitApp)
  window2.bind("Exit", exitApp)
     
  # Make Deno as the `.ts` and `.js` interpreter
  window.runtime = Deno

  # Show a new window
  window.show("index.html")

  # Wait until all windows get closed
  wait()

# set current dir to current source path so you
# don't have to look for the example/folder
setCurrentDir(currentSourcePath().parentDir())

main()