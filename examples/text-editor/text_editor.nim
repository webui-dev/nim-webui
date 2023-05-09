import std/os

import webui

proc main = 
  let window = newWindow()

  window.bind("Open") do (_: Event):
    echo "Open file."

  window.bind("Save") do (_: Event):
    echo "Save."

  window.bind("Close") do (_: Event):
    echo "Exit."

    exit()

  window.show("ui/MainWindow.html")

  wait()

# set current dir to current source path so you
# don't have to look for the example/folder
setCurrentDir(currentSourcePath().parentDir())

main()
