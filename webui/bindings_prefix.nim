## Nim bindings for [WebUI](https://github.com/webui-dev/webui)

runnableExamples:

  let window = newWindow() # Create a new Window
  window.show("<html>Hello</html>") # Show the window with html content in any browser

  wait() # Wait until the window gets closed

import std/os

const
  currentSourceDir = currentSourcePath().parentDir()
  useWebuiStaticLib* = defined(useWebuiStaticLib) or defined(useWebuiStaticLibrary)
  useWebuiDll* = defined(useWebuiDll)

when useWebuiStaticLib:
  const webuiStaticLib* {.strdefine.} =
    when defined(webuiTls):
      "webui-2-secure-static"
    else:
      "webui-2-static"

  # TODO link ssl libs
  when defined(vcc):
    {.link: "user32.lib".}
    {.link: "ws2_32.lib".}
    {.link: "Advapi32.lib".}

    {.link: webuiStaticLib & ".lib".}
  else:
    # * Order matters!!

    {.passL: "-L.".} # so gcc/clang can find the library
    {.passL: "-l" & webuiStaticLib.} # link the static library itself
    
    when defined(webuiTls):
      {.passL: "-lcrypto".}
      {.passL: "-lssl".}

      when defined(windows):
        {.passL: "-lbcrypt".}

    when defined(windows):
      {.passL: "-luser32".} # link dependencies
      {.passL: "-lws2_32".}
      {.passL: "-lAdvapi32".}

  {.pragma: webui, cdecl.}
elif useWebuiDll:
  const webuiDll* {.strdefine.} =
    block:
      var base = "./webui-2" # no lib prefix

      when defined(webuiTls):
        base &= "-secure"

      when defined(windows):
        base & ".dll"
      elif defined(macos):
        base & ".dylib"
      else:
        base & ".so"

  {.pragma: webui, dynlib: webuiDll, cdecl.}
else:
  # -d:webuiLog
  when defined(webuiLog):
    {.passC: "-DWEBUI_LOG".}
  
  # -d:webuiTLS
  when defined(webuiTLS):
    when defined(windows):
      {.passL: "-lbcrypt".}
  
    {.passL: "-lcrypto".}
    {.passL: "-lssl".}

    {.passC: "-DWEBUI_TLS".}
    {.passC: "-DNO_SSL_DL -DOPENSSL_API_1_1".}
  else:
    {.passC: "-DNO_SSL".}

  when defined(vcc):
    {.link: "ole32.lib".}
    {.link: "user32.lib".}
    {.link: "ws2_32.lib".}
    {.link: "Advapi32.lib".}

    {.passC: "/DMUST_IMPLEMENT_CLOCK_GETTIME".}
    {.passC: "/I " & currentSourceDir / "webui/include".}

  elif defined(windows):
    {.passL: "-lole32".}
    {.passL: "-lws2_32".}
    {.passL: "-luser32".}
    {.passL: "-lAdvapi32".}

    {.passC: "-I" & currentSourceDir / "webui/include".}

  else:
    {.passL: "-lpthread".}
    {.passL: "-lm".}

    {.passC: "-I" & currentSourceDir / "webui/include".}

  when defined(macos) or defined(macosx):
    {.passL: "-framework Cocoa -framework WebKit".}
    {.passC: "-I" & currentSourceDir / "webui/src/webview".}
    
    {.compile: currentSourceDir / "webui/src/webview/wkwebview.m".}
  
  # fix for cpp
  when (defined(clang) or defined(gcc)) and defined(cpp):
    {.passL: "-static".}

  {.passC: "-DNDEBUG -DNO_CACHING -DNO_CGI -DUSE_WEBSOCKET".}

  {.compile: currentSourceDir / "webui/src/civetweb/civetweb.c".}
  {.compile: currentSourceDir / "webui/src/webui.c".}

  {.pragma: webui, cdecl.}

import macros, sugar
import sequtils, strutils

proc snakeToCamel(renamed: string): string =
  var pos = 0
  var capitalizeNextChar = true
  result = ""
  while pos < renamed.len:
    if renamed[pos] == '_':
      capitalizeNextChar = true
    elif capitalizeNextChar:
      result.add(renamed[pos].toUpperAscii)
      capitalizeNextChar = false
    else:
      result.add(renamed[pos])
    pos += 1

proc renameEnumFieldName(oldName, enumTypeShortName: string): string =
  var renamed : string
  if "_" in oldName:
    renamed = oldName.toLowerAscii
    if renamed.startswith("webui_"):
      renamed = renamed.replace("webui_", "")
    if "_" in renamed:
      renamed = renamed[renamed.find("_") + 1 ..< renamed.len]
  else:
    renamed = oldName

  # snake to camel
  result = enumTypeShortName & renamed.snakeToCamel()

proc getLegacyConstantName(oldName: string): string =
  var renamed : string
  if "_" in oldName:
    renamed = oldName.toLowerAscii
    if renamed.startswith("webui_"):
      renamed = renamed.replace("webui_", "")
  else:
    renamed = oldName
  result = renamed.snakeToCamel()

macro renameEnumFields(enumdef : untyped): untyped =
  if enumdef.kind != nnkTypeDef:
    raise newException(Exception, "generateDeprecatedEnumConst macro can only be used on enum type definitions")
  
  let enumTypeName = enumdef[0][0][1].strVal
  let enumTypeShortName = enumTypeName.toSeq.map(x => (if (x in {'A'..'Z'}): $x else: "")).join("").toLowerAscii()

  # generate enum defs
  result = nnkTypeDef.newTree(
    nnkPostfix.newTree(
        newIdentNode("*"),
        newIdentNode(enumTypeName)
      ),
    newEmptyNode(),
    nnkEnumTy.newTree(
      newEmptyNode()
    )
  )
  for enumFieldNode in enumdef[2]:
    if enumFieldNode.kind == nnkEmpty:
      continue
    elif enumFieldNode.kind == nnkEnumFieldDef:
      result[2].add(
        nnkEnumFieldDef.newTree(
          newIdentNode(enumFieldNode[0].strVal.renameEnumFieldName(enumTypeShortName)),
          enumFieldNode[1]
        )
      )
    elif enumFieldNode.kind == nnkIdent:
      result[2].add(
        newIdentNode(enumFieldNode.strVal.renameEnumFieldName(enumTypeShortName))
      )
    else:
      raise newException(Exception, "generateDeprecatedEnumConst macro can only be used on enum type definitions")
  
  echo "[WebUI] Renaming Enum Definition:"
  echo "=".repeat(50)
  echo enumdef.repr
  echo "=".repeat(50)
  echo result.repr
  echo "_".repeat(50)


  # # generate legacy constants
  # var constStmt = nnkStmtList.newTree(
  #   nnkConstSection.newTree(
  #   )
  # )
  # for enumFieldNode in enumdef[2]:
  #   var constName, enumFieldName: string
  #   if enumFieldNode.kind == nnkEmpty:
  #     continue
  #   elif enumFieldNode.kind == nnkEnumFieldDef:
  #     constName = enumFieldNode[0].strVal.getLegacyConstantName()
  #     enumFieldName = enumFieldNode[0].strVal.renameEnumFieldName(enumTypeShortName)
  #   elif enumFieldNode.kind == nnkIdent:
  #     constName = enumFieldNode.strVal.getLegacyConstantName()
  #     enumFieldName = enumFieldNode.strVal.renameEnumFieldName(enumTypeShortName)
    
  #   constStmt[0].add(
  #     nnkConstDef.newTree(
  #       nnkPostfix.newTree(
  #         newIdentNode("*"),
  #         newIdentNode(constName)
  #       ),
  #       newEmptyNode(),
  #       nnkDotExpr.newTree(
  #         newIdentNode(enumTypeName),
  #         newIdentNode(enumFieldName)
  #       )
  #     )
  #   )

