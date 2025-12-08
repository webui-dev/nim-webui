import std/strformat
import std/os

import webui

var
  window: Window
  window2: Window

  count: int

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
      of WebuiEvent.weConnected:
        echo "Connected"
      of WebuiEvent.weDisconnected:
        echo "Disconnected"
      of WebuiEvent.weMouseClick:
        echo "Click"
      of WebuiEvent.weNavigation:
        echo "Starting navigation to: ", e.getString()    
      else:
        discard

  window.setFileHandler() do (filename: string) -> string:
    echo "File: ", filename

    case filename
    of "/test.txt":
      # Const static file example
      # Note: The connection will drop if the content
      # does not have `<script src="/webui.js"></script>`

      return "This is a embedded file content example."
    of "/dynamic.html":
      # Dynamic file example
      inc count

      return fmt"""
<html>
  This is a dynamic file content example.
  <br>
  Count: {count} <a href="dynamic.html">[Refresh]</a>
  <br>

  <script src="/webui.js"></script>
</html>
"""

    # By default, this function returns an empty string
    # returning an empty string will make WebUI look for 
    # the requested file locally

  window.bind("Exit", exitApp)
  window2.bind("Exit", exitApp)
     
  # Make Deno as the `.ts` and `.js` interpreter
  window.runtime = WebuiRuntime.wrDeno

  # Set root folder to current directory
  window.rootFolder = currentSourcePath().parentDir()
  window2.rootFolder = currentSourcePath().parentDir()

  # Set window size
  window.setSize(800, 600)

  # Set window position
  window.setPosition(100, 100)

  # Show a new window
  window.show("index.html")

  # Wait until all windows get closed
  wait()

main()
