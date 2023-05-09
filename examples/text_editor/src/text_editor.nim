import std/strutils
import std/os

import os_files/dialog
import webui

var
  filePath: string

proc main = 
  let window = newWindow()

  window.bind("Open") do (e: Event):
    var di: DialogInfo

    di.kind = dkOpenFile
    di.filters = @[
      (name: "Text files", ext: "*.txt"),
      (name: "Any file", ext: "*")
    ]

    let tfp = di.show()

    if tfp.len == 0:
      return
    else:
      filePath = tfp

    e.window.run("addText('$1')" % encode(readFile(filePath)))
    e.window.run("SetFile('$1')" % encode(filePath))

  window.bind("Save") do (e: Event):
    writeFile(filePath, e.data)

  window.bind("Close") do (_: Event):
    echo "Exit."

    exit()

  window.show("ui/MainWindow.html")

  wait()

# set current dir to current source path so you
# don't have to look for the example/folder
setCurrentDir(currentSourcePath().parentDir())

main()
