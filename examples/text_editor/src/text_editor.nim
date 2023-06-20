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
    di.title = "Text Editor"
    di.filters = @[
      (name: "Text files", ext: "*.txt"),
      (name: "HTML/XHTML source files", ext: "*.html;*.html;*.xhtml"),
      (name: "Javascript Files", ext: "*.js;*.jsx;*.ts;*.tsx"),
      (name: "Stylesheets", ext: "*.css;*.less;*.sass;*.scss;*.styl;*.bass"),
      (name: "Nim source files", ext: "*.nim;*.nims;*.nimble;*.nimf;nim.cfg;nimdoc.cfg"),
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

  # Set root folder
  window.rootFolder = currentSourcePath().parentDir() / "ui"

  window.show("MainWindow.html")

  wait()

main()
