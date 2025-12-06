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

