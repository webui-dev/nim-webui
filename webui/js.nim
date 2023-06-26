import std/htmlparser
import std/tempfiles
import std/strutils
import std/xmltree
import std/macros
import std/osproc
import std/os

import ../webui

#let (file, path) = createTempFile("tmpnim_", "webui.nim")
#file.write quote(body).astToStr
#file.close()
#echo path

var code*: seq[string]

proc nimToJs*(nimCode: string): string = 
  let (file, path) = createTempFile("tmpnim_", "webui.nim")
  file.write nimCode
  file.close()

  echo path

  discard execProcess(
    "nim",
    getCurrentDir(),
    ["js", "-d:release", "-d:danger", "--opt:size", path],
    options={poUsePath, poStdErrToStdOut}
    )

  return readFile(path.changeFileExt("js"))

macro getCodeAsStr*(body: untyped): string =
  return newStrLitNode(repr body)

macro jsCodeImpl*(body: untyped): string =
  if body.kind() == nnkProcDef:
    body.addPragma(ident"exportc")

  return newStrLitNode(repr body)

template jsCode*(body: untyped) = 
  code.add jsCodeImpl(body)

# alias for `jsCode`
template jsProc*(body: untyped) = 
  code.add jsCodeImpl(body)

template runJs*(window: Window, body: untyped) =
  let js = nimToJs(getCodeAsStr(body))

  window.run(js)

template scriptJs*(window: Window, body: untyped): tuple[data: string; error: bool] =
  let js = nimToJs(getCodeAsStr(body))

  window.script(js, bufferLen = 4000)

# TODO fix approach? parsing the html isnt the best
proc collectJs*(html: string): string = 
  let collectedCode = code.join()

  let (file, path) = createTempFile("tmpnim_", "webui.nim")
  file.write collectedCode
  file.close()

  echo path

  discard execProcess(
    "nim",
    getCurrentDir(),
    ["js", "-d:release", "-d:danger", "--opt:size", path],
    options={poUsePath, poStdErrToStdOut}
    )

  let js = readFile(path.changeFileExt("js"))

  #[
  var 
    xml = if html.fileExists(): loadHtml(html)
          else: parseHtml(html)
            
    node = newElement("script")
  
  node.attrs = toXmlAttributes {"defer": "true"}
  node.add newVerbatimText js

  xml[1][1].add node

  writeFile("z.html", $xml)

  return $xml
  ]#

when isMainModule:
  proc thisorthat(who: string, where: int) {.jsCode.} = 
    let this = where * 5

    echo this
    echo who, '?'

  echo collectJs("./examples/serve_folder/index.html")