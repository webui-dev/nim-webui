import ../webui

#[
import ../webui/bindings

proc main2 = 
  # Create a new window
  let window = newWindow()

  # Bind an HTML element ID with a C function
  discard window.bind("SwitchToSecondPage") do (e: ptr Event) {.cdecl.}:
    discard e.window.open("second.html", 0)

  discard window.bind("Exit") do (_: ptr Event) {.cdecl.}:
    bindings.exit()

  # The root path. Leave it empty to let the WebUI
  # automatically select the current working folder
  let rootPath = ""

  let link = newServer(window, cstring rootPath)

  if not window.open(link, 1):  # Run the window on Chrome
    discard window.open(link, 0) # If not, run on any other installed web browser

  # Wait until all windows get closed
  wait()

main2()
]#

proc main = 
  # Create a new window
  let window = newWindow()

  # Bind an HTML element ID with a C function
  window.bind("SwitchToSecondPage") do (e: Event):
    e.window.open("second.html")

  window.bind("Exit") do (_: Event):
    webui.exit()

  # The root path. Leave it empty to let the WebUI
  # automatically select the current working folder
  let rootPath = ""

  let link = newServer(window, rootPath)

  if not window.open(link, BrowserChrome):  # Run the window on Chrome
    window.open(link, BrowserAny) # If not, run on any other installed web browser

  # Wait until all windows get closed
  wait()

main()