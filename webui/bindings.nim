## Nim bindings for [WebUI](https://github.com/alifcommunity/webui)

runnableExamples:

  let window = newWindow() # Create a new Window
  window.show("<html>Hello</html>") # Show the window with html content in any browser

  wait() # Wait until the window gets closed


import std/os

const
  currentSourceDir {.used.} = currentSourcePath().parentDir()

  useWebuiStaticLib* = defined(useWebuiStaticLib) or defined(useWebuiStaticLibrary)
  useWebuiDll* = defined(useWebuiDll)

when useWebuiStaticLib:
  const webuiStaticLib* {.strdefine.} = "webui-2-static-x64"

  when defined(vcc):
    {.link: "user32.lib".}
    {.link: "ws2_32.lib".}
    {.link: "Advapi32.lib".}

    {.link: webuiStaticLib & ".lib".}
  else:
    # * Order matters!!

    {.passL: "-L.".} # so gcc/clang can find the library

    {.passL: "-l" & webuiStaticLib.} # link the static library itself

    {.passL: "-luser32".} # link dependencies
    {.passL: "-lws2_32".}
    {.passL: "-lAdvapi32".}

  {.pragma: webui, discardable.}
elif useWebuiDll:
  const webuiDll* {.strdefine.} = when defined(windows):
    "webui-2-x64.dll"
  elif defined(macos):
    "webui-2-x64.dyn"
  else:
    "webui-2-x64.so" # no lib prefix

  {.pragma: webui, dynlib: webuiDll, discardable.}
else:
  # -d:webuiLog
  when defined(webuiLog):
    {.passC: "-DWEBUI_LOG".}

  when defined(vcc):
    {.link: "user32.lib".}
    {.link: "ws2_32.lib".}
    {.link: "Advapi32.lib".}

    {.passC: "/I " & currentSourceDir / "webui" / "include".}

  elif defined(windows):
    {.passL: "-lws2_32".}
    {.passL: "-luser32".}
    {.passL: "-lAdvapi32".}

    {.passC: "-I" & currentSourceDir / "webui" / "include".}

  when defined(linux) or defined(macosx):
    {.passL: "-lpthread".}
    {.passL: "-lm".}

    {.passC: "-I" & currentSourceDir / "webui" / "include".}

  {.pragma: webui, discardable.}
  
  {.compile: "./webui/src/mongoose.c".}
  {.compile: "./webui/src/webui.c".}

{.deadCodeElim: on.}

const
  WEBUI_VERSION*                   = "2.2.0"   ## Version

# -- Types -------------------------

type
  Browsers* {.bycopy.} = enum
    BrowsersAny
    BrowsersChrome
    BrowsersFirefox
    BrowsersEdge
    BrowsersSafari
    BrowsersChromium
    BrowsersOpera
    BrowsersBrave
    BrowsersVivaldi
    BrowsersEpic
    BrowsersYandex 

  Events* {.bycopy.} = enum
    EventsDisconnected
    EventsConnected
    EventsMultiConnection
    EventsUnwantedConnection
    EventsMouseClick
    EventsNavigation
    EventsCallback

  Event* {.bycopy.} = object
    element*: cstring
    window*: pointer
    data*: cstring
    response*: cstring
    `type`*: cuint

  Runtime* {.bycopy.} = enum
    None
    Deno
    NodeJS

##  -- Definitions ---------------------
proc newWindow*(): pointer {.cdecl, importc: "webui_new_window".}
  ##  Create a new webui window object.

proc `bind`*(window: pointer; element: cstring; `func`: proc (e: ptr Event) {.cdecl.}): cuint {.
    cdecl, importc: "webui_bind".}
  ##  Bind a specific html element click event with a function. Empty element means all events.
 
proc show*(window: pointer; content: cstring): bool {.cdecl, importc: "webui_show".}
  ##  Show a window using a embedded HTML, or a file. If the window is already opened then it will be refreshed.

proc showBrowser*(window: pointer; content: cstring; browser: cuint): bool {.cdecl,
    importc: "webui_show_browser".}
  ##  Same as webui_show(). But with a specific web browser.

proc wait*() {.cdecl, importc: "webui_wait".}
  ##  Wait until all opened windows get closed.

proc close*(window: pointer) {.cdecl, importc: "webui_close".}
  ##  Close a specific window.

proc exit*() {.cdecl, importc: "webui_exit".}
  ##  Close all opened windows. webui_wait() will break.

##  -- Other ---------------------------
proc isShown*(window: pointer): bool {.cdecl, importc: "webui_is_shown".}
  ##  Check a specific window if it's still running

proc setTimeout*(second: cuint) {.cdecl, importc: "webui_set_timeout".}
  ##  Set the maximum time in seconds to wait for browser to start

proc setIcon*(window: pointer; icon: cstring; `type`: cstring) {.cdecl,
    importc: "webui_set_icon".}
  ##  Set the default embedded HTML favicon

proc setMultiAccess*(window: pointer; status: bool) {.cdecl,
    importc: "webui_set_multi_access".}
  ##  Allow the window URL to be re-used in normal web browsers

##  -- JavaScript ----------------------
proc run*(window: pointer; script: cstring): bool {.cdecl, importc: "webui_run".}
  ##  Run JavaScript quickly with no waiting for the response.

proc script*(window: pointer; script: cstring; timeout: cuint; buffer: cstring;
            bufferLength: csize_t): bool {.cdecl, importc: "webui_script".}
  ##  Run a JavaScript, and get the response back (Make sure your local buffer can hold the response).

proc setRuntime*(window: pointer; runtime: cuint) {.cdecl,
    importc: "webui_set_runtime".}
  ##  Chose between Deno and Nodejs runtime for .js and .ts files.

proc getInt*(e: ptr Event): clonglong {.cdecl, importc: "webui_get_int".}
  ##  Parse argument as integer.

proc getString*(e: ptr Event): cstring {.cdecl, importc: "webui_get_string".}
  ##  Parse argument as string.

proc getBool*(e: ptr Event): bool {.cdecl, importc: "webui_get_bool".}
  ##  Parse argument as boolean.

proc returnInt*(e: ptr Event; n: clonglong) {.cdecl, importc: "webui_return_int".}
  ##  Return the response to JavaScript as integer.

proc returnString*(e: ptr Event; s: cstring) {.cdecl, importc: "webui_return_string".}
  ##  Return the response to JavaScript as string.

proc returnBool*(e: ptr Event; b: bool) {.cdecl, importc: "webui_return_bool".}
  ##  Return the response to JavaScript as boolean.

##  -- Interface -----------------------
proc interfaceBind*(window: pointer; element: cstring; `func`: proc (a1: pointer;
    a2: cuint; a3: cstring; a4: cstring; a5: cstring) {.cdecl.}): cuint {.cdecl,
    importc: "webui_interface_bind".}
  ##  Bind a specific html element click event with a function. Empty element means all events. This replace webui_bind(). The func is (Window, EventType, Element, Data, Response)

proc interfaceSetResponse*(`ptr`: cstring; response: cstring) {.cdecl,
    importc: "webui_interface_set_response".}
  ##  When using `webui_interface_bind()` you need this function to easily set your callback response.

proc interfaceIsAppRunning*(): bool {.cdecl,
                                   importc: "webui_interface_is_app_running".}
  ##  Check if the app still running or not. This replace webui_wait().

proc interfaceGetWindowId*(window: pointer): cuint {.cdecl,
    importc: "webui_interface_get_window_id".}
  ##  Get window unique ID
