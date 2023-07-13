import std/strutils

# Package

version       = "2.3.0.4"
author        = "Jasmine"
description   = "Wrapper for WebUI"
license       = "MIT"
installFiles  = @["webui.nim"]
installDirs   = @["webui"]


# Tasks

proc xxd*(inputfile, outputFile: string) = 
  var 
    output: string
    content: string
  
  let input = readFile(inputFile)

  output.add "unsigned char webui_js[] = {\n"

  for idx, c in input:
    content.add "0x" & toHex($c).toLowerAscii()
    
    if idx != input.len - 1:
      content.add ", "

    if (idx + 1) mod 12 == 0:
      content.add '\n'

  output.add content.indent(2)
  output.add '\n'
  output.add "};\n"

  output.add "unsigned int webui_js_len = $1;\n" % $input.len

  outputFile.writeFile(output)

after install:
  withDir("webui/webui/src/client"):
    xxd("webui.js", "webui.h")


# Dependencies

requires "nim >= 1.4.0"
