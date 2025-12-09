## Nim bindings for [WebUI](https://github.com/webui-dev/webui)

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

template helper(body:untyped):untyped = body

macro renameEnumFields(enumdef : untyped): untyped =
  ## renameEnumFields is a type pragma macro to change enum definition, so that it's compatible with 
  ## the old versions.
  ## 
  ## The following results are output during compileTime. For example, WebuiBrowser.NoBrowser
  ## will be renamed to WebuiBrowser.wbNoBrowser. Note that "wb" is a short name for "WebuiBrowser", and 
  ## it's used to prefix the original enum field to avoid potential naming collisions.
  ## 
  ## There is also a generated `let` variable definition to mimic the legacy constant
  ## `let NoBrowser* = WebuiBrowserHelper.wbNoBrowser`
  ## 
  ## ==================================================
  ## [WebUI] Renaming Enum Definition:
  ## ## Original Enum Def:
  ## ==================================================
  ## WebuiBrowser* {..} = enum   ## -- Enums ---------------------------
  ##   NoBrowser = 0,            ## 0. No web browser
  ##   AnyBrowser = 1,           ## 1. Default recommended web browser
  ##   Chrome,                   ## 2. Google Chrome
  ##   Firefox,                  ## 3. Mozilla Firefox
  ##   Edge,                     ## 4. Microsoft Edge
  ##   Safari,                   ## 5. Apple Safari
  ##   Chromium,                 ## 6. The Chromium Project
  ##   Opera,                    ## 7. Opera Browser
  ##   Brave,                    ## 8. The Brave Browser
  ##   Vivaldi,                  ## 9. The Vivaldi Browser
  ##   Epic,                     ## 10. The Epic Browser
  ##   Yandex,                   ## 11. The Yandex Browser
  ##   ChromiumBased,            ## 12. Any Chromium based browser
  ##   Webview                    ## 13. WebView (Non-web-browser)
  ## ==================================================
  ## ## Renamed Enum Def:
  ## WebuiBrowser* = enum
  ##   wbNoBrowser = 0, wbAnyBrowser = 1, wbChrome, wbFirefox, wbEdge, wbSafari,
  ##   wbChromium, wbOpera, wbBrave, wbVivaldi, wbEpic, wbYandex, wbChromiumBased,
  ##   wbWebview
  ## ==================================================
  ## ## Generated procs to mimic legacy constants:
  ## let NoBrowser* = WebuiBrowserHelper.wbNoBrowser
  ## let AnyBrowser* = WebuiBrowserHelper.wbAnyBrowser
  ## let Chrome* = WebuiBrowserHelper.wbChrome
  ## let Firefox* = WebuiBrowserHelper.wbFirefox
  ## let Edge* = WebuiBrowserHelper.wbEdge
  ## let Safari* = WebuiBrowserHelper.wbSafari
  ## let Chromium* = WebuiBrowserHelper.wbChromium
  ## let Opera* = WebuiBrowserHelper.wbOpera
  ## let Brave* = WebuiBrowserHelper.wbBrave
  ## let Vivaldi* = WebuiBrowserHelper.wbVivaldi
  ## let Epic* = WebuiBrowserHelper.wbEpic
  ## let Yandex* = WebuiBrowserHelper.wbYandex
  ## let ChromiumBased* = WebuiBrowserHelper.wbChromiumBased
  ## let Webview* = WebuiBrowserHelper.wbWebview
  ## **************************************************


  ## ==================================================
  ## [WebUI] Renaming Enum Definition:
  ## ## Original Enum Def:
  ## ==================================================
  ## WebuiRuntime* {..} = enum
  ##   None = 0,                 ## 0. Prevent WebUI from using any runtime for .js and .ts files
  ##   Deno,                     ## 1. Use Deno runtime for .js and .ts files
  ##   NodeJS,                   ## 2. Use Nodejs runtime for .js files
  ##   Bun                        ## 3. Use Bun runtime for .js and .ts files
  ## ==================================================
  ## ## Renamed Enum Def:
  ## WebuiRuntime* = enum
  ##   wrNone = 0, wrDeno, wrNodeJS, wrBun
  ## ==================================================
  ## ## Generated procs to mimic legacy constants:
  ## let None* = WebuiRuntimeHelper.wrNone
  ## let Deno* = WebuiRuntimeHelper.wrDeno
  ## let NodeJS* = WebuiRuntimeHelper.wrNodeJS
  ## let Bun* = WebuiRuntimeHelper.wrBun
  ## **************************************************


  ## ==================================================
  ## [WebUI] Renaming Enum Definition:
  ## ## Original Enum Def:
  ## ==================================================
  ## WebuiEvent* {..} = enum
  ##   WEBUI_EVENTS_DISCONNECTED = 0, ## 0. Window disconnection event
  ##   WEBUI_EVENTS_CONNECTED,   ## 1. Window connection event
  ##   WEBUI_EVENTS_MOUSE_CLICK, ## 2. Mouse click event
  ##   WEBUI_EVENTS_NAVIGATION,  ## 3. Window navigation event
  ##   WEBUI_EVENTS_CALLBACK      ## 4. Function call event
  ## ==================================================
  ## ## Renamed Enum Def:
  ## WebuiEvent* = enum
  ##   weDisconnected = 0, weConnected, weMouseClick, weNavigation, weCallback
  ## ==================================================
  ## ## Generated procs to mimic legacy constants:
  ## let EventsDisconnected* = WebuiEventHelper.weDisconnected
  ## let EventsConnected* = WebuiEventHelper.weConnected
  ## let EventsMouseClick* = WebuiEventHelper.weMouseClick
  ## let EventsNavigation* = WebuiEventHelper.weNavigation
  ## let EventsCallback* = WebuiEventHelper.weCallback
  ## **************************************************


  ## ==================================================
  ## [WebUI] Renaming Enum Definition:
  ## ## Original Enum Def:
  ## ==================================================
  ## WebuiConfig* {..} = enum
  ##   show_wait_connection = 0, ## Control if WebUI should block and process the UI events
  ##                              ## one a time in a single thread `True`, or process every
  ##                              ## event in a new non-blocking thread `False`. This updates
  ##                              ## all windows. You can use `webui_set_event_blocking()` for
  ##                              ## a specific single window update.
  ##                              ## 
  ##                              ## Default: False
  ##   ui_event_blocking, ## Automatically refresh the window UI when any file in the
  ##                       ## root folder gets changed.
  ##                       ## 
  ##                       ## Default: False
  ##   folder_monitor, ## Allow multiple clients to connect to the same window,
  ##                    ## This is helpful for web apps (non-desktop software),
  ##                    ## Please see the documentation for more details.
  ##                    ## 
  ##                    ## Default: False
  ##   multi_client, ## Allow or prevent WebUI from adding `webui_auth` cookies.
  ##                  ## WebUI uses these cookies to identify clients and block
  ##                  ## unauthorized access to the window content using a URL.
  ##                  ## Please keep this option to `True` if you want only a single
  ##                  ## client to access the window content.
  ##                  ## 
  ##                  ## Default: True
  ##   use_cookies, ## If the backend uses asynchronous operations, set this
  ##                 ## option to `True`. This will make webui wait until the
  ##                 ## backend sets a response using `webui_return_x()`.
  ##   asynchronous_response
  ## ==================================================
  ## ## Renamed Enum Def:
  ## WebuiConfig* = enum
  ##   wcWaitConnection = 0, wcEventBlocking, wcMonitor, wcClient, wcCookies,
  ##   wcResponse
  ## ==================================================
  ## ## Generated procs to mimic legacy constants:
  ## let ShowWaitConnection* = WebuiConfigHelper.wcWaitConnection
  ## let UiEventBlocking* = WebuiConfigHelper.wcEventBlocking
  ## let FolderMonitor* = WebuiConfigHelper.wcMonitor
  ## let MultiClient* = WebuiConfigHelper.wcClient
  ## let UseCookies* = WebuiConfigHelper.wcCookies
  ## let AsynchronousResponse* = WebuiConfigHelper.wcResponse
  ## **************************************************


  if enumdef.kind != nnkTypeDef:
    raise newException(Exception, "generateDeprecatedEnumConst macro can only be used on enum type definitions")
  
  let enumTypeName = enumdef[0][0][1].strVal
  let enumTypeShortName = enumTypeName.toSeq.map(x => (if (x in {'A'..'Z'}): $x else: "")).join("").toLowerAscii()

  # generate enum defs
  var renamedEnumDef = nnkTypeDef.newTree(
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
      renamedEnumDef[2].add(
        nnkEnumFieldDef.newTree(
          newIdentNode(enumFieldNode[0].strVal.renameEnumFieldName(enumTypeShortName)),
          enumFieldNode[1]
        )
      )
    elif enumFieldNode.kind == nnkIdent:
      renamedEnumDef[2].add(
        newIdentNode(enumFieldNode.strVal.renameEnumFieldName(enumTypeShortName))
      )
    else:
      raise newException(Exception, "generateDeprecatedEnumConst macro can only be used on enum type definitions")
  
  # echo "\n\n" & "=".repeat(50)
  # echo "[WebUI] Renaming Enum Definition:"
  # echo "# Original Enum Def:"
  # echo "=".repeat(50)
  # echo enumdef.repr
  # echo "=".repeat(50)
  # echo "# Renamed Enum Def:"
  # echo renamedEnumDef.repr
  # echo "=".repeat(50)
  # echo "# Generated procs to mimic legacy constants:"
  
  renamedEnumDef[0][1] = (enumTypeName & "Helper").newIdentNode()

  var statements = nnkStmtList.newTree(
    nnkTypeSection.newTree(
      renamedEnumDef
    )
  )

  # add procs to mimic legacy constants
  for enumFieldNode in enumdef[2]:
    var constName, enumFieldName: string
    if enumFieldNode.kind == nnkEmpty:
      continue
    elif enumFieldNode.kind == nnkEnumFieldDef:
      constName = enumFieldNode[0].strVal.getLegacyConstantName()
      enumFieldName = enumFieldNode[0].strVal.renameEnumFieldName(enumTypeShortName)
    elif enumFieldNode.kind == nnkIdent:
      constName = enumFieldNode.strVal.getLegacyConstantName()
      enumFieldName = enumFieldNode.strVal.renameEnumFieldName(enumTypeShortName)
    
    # statements.add(
    #   nnkProcDef.newTree(
    #     nnkPostfix.newTree(
    #       newIdentNode("*"),
    #       newIdentNode(constName)
    #     ),
    #     newEmptyNode(),
    #     newEmptyNode(),
    #     nnkFormalParams.newTree(
    #       newIdentNode(enumTypeName & "Helper")
    #     ),
    #     nnkPragma.newTree(
    #       newIdentNode("inline"),
    #       newIdentNode("deprecated")
    #     ),
    #     newEmptyNode(),
    #     nnkStmtList.newTree(
    #       nnkDotExpr.newTree(
    #         newIdentNode(enumTypeName & "Helper"),
    #         newIdentNode(enumFieldName)
    #       )
    #       )
    #     )
    #   )
    statements.add(
      nnkLetSection.newTree(
        nnkIdentDefs.newTree(
          nnkPostfix.newTree(
            newIdentNode("*"),
            newIdentNode(constName)
          ),
          newEmptyNode(),
          nnkDotExpr.newTree(
            newIdentNode(enumTypeName & "Helper"),
            newIdentNode(enumFieldName)
          )
        )
      )
    )
    
    # echo statements[^1].repr

  # echo "*".repeat(50)

  statements.add(
    (enumTypeName & "Helper").newIdentNode()
  )

  result = nnkTypeDef.newTree(
        nnkPostfix.newTree(
            newIdentNode("*"),
            newIdentNode(enumTypeName)
        ),
        newEmptyNode(),
        nnkCall.newTree(
            newIdentNode("helper"),
            statements
        )
    )

  # echo result