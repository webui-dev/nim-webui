import webui
import ./vfs

proc main() =
  # Create new windows
  let window = newWindow()

  # Bind HTML element IDs with a Nim functions
  window.bind("Exit") do (_: Event):
    exit()

  # Set a custom file handler
  window.fileHandler = vfs.fileHandler

  # Show the new window
  # window.show("index.html", wbChrome)
  window.show("index.html")

  # Wait until all windows get closed
  wait()

  # Free all memory resources (Optional)
  clean()

main()
