## Nim bindings for [WebUI](https://github.com/webui-dev/webui)

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
  const webuiStaticLib* {.strdefine.} = "webui-2-static"

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

  {.pragma: webui, cdecl.}
elif useWebuiDll:
  const webuiDll* {.strdefine.} = when defined(windows):
    "webui-2.dll"
  elif defined(macos):
    "webui-2.dyn"
  else:
    "webui-2.so" # no lib prefix

  {.pragma: webui, dynlib: webuiDll, cdecl.}
else:
  # -d:webuiLog
  when defined(webuiLog):
    {.passC: "-DWEBUI_LOG".}
  
  # -d:webuiTLS
  when defined(webuiTLS):
    {.passC: "-DWEBUI_TLS".}

  when defined(vcc):
    {.link: "ole32.lib".}
    {.link: "user32.lib".}
    {.link: "ws2_32.lib".}
    {.link: "Advapi32.lib".}

    {.passC: "/I " & currentSourceDir / "webui" / "include".}

  elif defined(windows):
    {.passL: "-lole32".}
    {.passL: "-lws2_32".}
    {.passL: "-luser32".}
    {.passL: "-lAdvapi32".}

    {.passC: "-I" & currentSourceDir / "webui" / "include".}

  when defined(linux) or defined(macosx):
    {.passL: "-lpthread".}
    {.passL: "-lm".}

    {.passC: "-I" & currentSourceDir / "webui" / "include".}

  when defined(macos):
    {.compile: currentSourceDir / "webui" / "src" / "wkwebview.m".}

    {.passC: "-I" & currentSourceDir / "webui" / "src" / "webview".}
    {.passL: "-framework Cocoa -framework WebKit".}

  {.pragma: webui, cdecl.}

  {.passC: "-DNDEBUG -DNO_CACHING -DNO_CGI -DNO_SSL -DUSE_WEBSOCKET -DMUST_IMPLEMENT_CLOCK_GETTIME".}

  {.compile: currentSourceDir / "webui/src/civetweb/civetweb.c".}
  {.compile: currentSourceDir / "webui/src/webui.c".}

const
  WEBUI_VERSION* = "2.5.0-Beta-1" ## Version
  WEBUI_MAX_IDS* = (256)
  WEBUI_MAX_ARG* = (16)

# -- Types -------------------------

type
  Browser* {.pure.} = enum
    NoBrowser     ## 0. No web browser
    Any           ## 1. Default recommended web browser
    Chrome        ## 2. Google Chrome
    Firefox       ## 3. Mozilla Firefox
    Edge          ## 4. Microsoft Edge
    Safari        ## 5. Apple Safari
    Chromium      ## 6. The Chromium Project
    Opera         ## 7. Opera Browser
    Brave         ## 8. The Brave Browser
    Vivaldi       ## 9. The Vivaldi Browser
    Epic          ## 10. The Epic Browser
    Yandex        ## 11. The Yandex Browser
    ChromiumBased ## 12. Any Chromium based browser

  Runtime* {.pure.} = enum
    None   ## 0. Prevent WebUI from using any runtime for .js and .ts files
    Deno   ## 1. Use Deno runtime for .js and .ts files
    NodeJS ## 2. Use Nodejs runtime for .js files

  Events* = enum
    EventsDisconnected       ## 0. Window disconnection event
    EventsConnected          ## 1. Window connection event
    EventsMultiConnection    ## 2. New window connection event
    EventsUnwantedConnection ## 3. New unwanted window connection event
    EventsMouseClick         ## 4. Mouse click event
    EventsNavigation         ## 5. Window navigation event
    EventsCallback           ## 6. Function call event

  WebuiConfigs* = enum
    wcShowWaitConnection
      ## Control if `show()` and `showX()` (e.g. `showBrowser()` & `showWv`) should wait
      ## for the window to connect before returns or not.
      ## Default: `true`

  Event* {.bycopy.} = object
    window*: csize_t      ## The window object number
    eventType*: csize_t   ## Event type
    element*: cstring     ## HTML element ID
    eventNumber*: csize_t ## Internal WebUI
    bindId*: csize_t      ## Bind ID

#  -- Definitions ---------------------

proc newWindow*(): csize_t {.webui, importc: "webui_new_window".}
  ##  Create a new WebUI window object.

proc newWindowId*(windowNumber: csize_t): csize_t {.webui, importc: "webui_new_window_id".}
  ##  Create a new webui window object using a specified window number.

proc getNewWindowId*(): csize_t {.webui, importc: "webui_get_new_window_id".}
  ##  Get a free window number that can be used with `newWindowId()`

proc `bind`*(window: csize_t; element: cstring; `func`: proc (e: ptr Event) {.cdecl.}): csize_t {.webui,
    importc: "webui_bind".}
  ##  Bind a specific html element click event with a function. Empty element means all events.

proc getBestBrowser*(window: csize_t): csize_t {.webui, importc: "webui_get_best_browser".}
  ##  Get the "best" browser to be used. If running `show()` or passing `Browsers.AnyBrowser` to `showBrowser()`, this function will return the same browser that will be used.

proc show*(window: csize_t; content: cstring): bool {.webui, importc: "webui_show".}
  ##  Show a window using embedded HTML, or a file. If the window is already open, it will be refreshed.

proc showBrowser*(window: csize_t; content: cstring; browser: csize_t): bool {.webui, importc: "webui_show_browser".}
  ##  Same as `show()`, but using a specific web browser.

proc showWv*(window: csize_t; content: cstring): bool {.webui, importc: "webui_show_wv".}
  ##  Show a WebView window using embedded HTML, or a file. If the window is already
  ##  open, it will be refreshed.
  ##
  ## .. note:: Windows needs `WebView2Loader.dll`.

proc setKiosk*(window: csize_t; status: bool) {.webui, importc: "webui_set_kiosk".}
  ##  Set the window in Kiosk mode (Full screen)

proc wait*() {.webui, importc: "webui_wait".}
  ##  Wait until all opened windows get closed.

proc close*(window: csize_t) {.webui, importc: "webui_close".}
  ##  Close a specific window only. The window object will still exist.

proc destroy*(window: csize_t) {.webui, importc: "webui_destroy".}
  ##  Close a specific window and free all memory resources.

proc exit*() {.webui, importc: "webui_exit".}
  ##  Close all open windows. `wait()` will return (Break).

proc setRootFolder*(window: csize_t; path: cstring): bool {.webui, importc: "webui_set_root_folder".}
  ##  Set the web-server root folder path for a specific window.

proc setDefaultRootFolder*(path: cstring): bool {.webui, importc: "webui_default_set_root_folder".}
  ##  Set the web-server root folder path for all windows. Should be used before `show()`.

proc setFileHandler*(window: csize_t; handler: proc (filename: cstring; length: ptr cint): pointer {.cdecl.}) {.webui,
    importc: "webui_set_file_handler".}
  ##  Set a custom handler to serve files.

proc isShown*(window: csize_t): bool {.webui, importc: "webui_is_shown".}
  ##  Check if the specified window is still running.

proc setTimeout*(second: csize_t) {.webui, importc: "webui_set_timeout".}
  ##  Set the maximum time in seconds to wait for the browser to start.

proc setIcon*(window: csize_t; icon: cstring; `type`: cstring) {.webui, importc: "webui_set_icon".}
  ##  Set the default embedded HTML favicon.

proc encode*(str: cstring): cstring {.webui, importc: "webui_encode".}
  ##  Base64 encoding. Use this to safely send text based data to the UI.
  ##  If it fails it will return `nil`.

proc decode*(str: cstring): cstring {.webui, importc: "webui_decode".}
  ##  Base64 decoding. Use this to safely decode received Base64 text from the UI.
  ##  If it fails it will return `nil`.

proc free*(`ptr`: pointer) {.webui, importc: "webui_free".}
  ##  Safely free a buffer allocated by WebUI using `malloc()`.

proc malloc*(size: csize_t): pointer {.webui, importc: "webui_malloc".}
  ##  Safely allocate memory using the WebUI memory management system. It
  ##  can be safely freed using `free()` at any time.

proc sendRaw*(window: csize_t; function: cstring; raw: pointer; size: csize_t) {.webui, importc: "webui_send_raw".}
  ##  Safely send raw data to the UI.

proc setHide*(window: csize_t; status: bool) {.webui, importc: "webui_set_hide".}
  ##  Set a window in hidden mode. Should be called before `show()`.

proc setSize*(window: csize_t; width: cuint; height: cuint) {.webui, importc: "webui_set_size".}
  ##  Set the window size.

proc setPosition*(window: csize_t; x: cuint; y: cuint) {.webui, importc: "webui_set_position".}
  ##  Set the window position.

proc setProfile*(window: csize_t; name: cstring; path: cstring) {.webui, importc: "webui_set_profile".}
  ##  Set the web browser profile to use. An empty `name` and `path` means
  ##  the default user profile. Must be called before `show()`.

proc setProxy*(window: csize_t; proxy_server: cstring) {.webui, importc: "webui_set_proxy".}
  ##  Set the web browser to use `proxy_server`. Must be called before `show()`.

proc getUrl*(window: csize_t): cstring {.webui, importc: "webui_get_url".}
  ##  Get the full current URL.

proc setPublic*(window: csize_t; status: bool) {.webui, importc: "webui_set_public".}
  ##  Allow a specific window address to be accessible from a public network

proc navigate*(window: csize_t; url: cstring) {.webui, importc: "webui_navigate".}
  ##  Navigate to a specific URL

proc clean*() {.webui, importc: "webui_clean".}
  ##  Free all memory resources. Should be called only at the end.

proc deleteAllProfiles*() {.webui, importc: "webui_delete_all_profiles".}
  ##  Delete all local web-browser profiles folder. It should called at the end.

proc deleteProfile*(window: csize_t) {.webui, importc: "webui_delete_profile".}
  ##  Delete a specific window web-browser local folder profile.

proc getParentProcessId*(window: csize_t): csize_t {.webui, importc: "webui_get_parent_process_id".}
  ##  Get the ID of the parent process (The web browser may re-create
  ##  another new process).

proc getChildProcessId*(window: csize_t): csize_t {.webui, importc: "webui_get_child_process_id".}
  ##  Get the ID of the last child process.

proc setPort*(window: csize_t; port: csize_t): bool {.webui, importc: "webui_set_port", discardable.}
  ##  Set a custom web-server network port to be used by WebUI.
  ##  This can be useful to determine the HTTP link of `webui.js` in case
  ##  you are trying to use WebUI with an external web-server like NGNIX

proc config*(option: WebuiConfigs; status: bool) {.webui, importc: "webui_config".}
  ## Control WebUI's behaviour. It's better to this call at the beginning.

# -- SSL/TLS -------------------------

proc setTlsCertificate*(certificate_pem: cstring; private_key_pem: cstring): bool {.webui,
    importc: "webui_set_tls_certificate".}
  ##  Set the SSL/TLS certificate and the private key content, both in PEM
  ##  format. This works only with `webui-2-secure` library. If set empty WebUI
  ##  will generate a self-signed certificate.

# -- JavaScript ----------------------

proc run*(window: csize_t; script: cstring) {.webui, importc: "webui_run".}
  ##  Run JavaScript without waiting for the response.

proc script*(window: csize_t; script: cstring; timeout: csize_t; buffer: cstring; bufferLength: csize_t): bool {.webui,
    importc: "webui_script".}
  ##  Run JavaScript and get the response back.
  ##  Make sure your local buffer can hold the response.

proc setRuntime*(window: csize_t; runtime: csize_t) {.webui, importc: "webui_set_runtime".}
  ##  Chose between Deno and Nodejs as runtime for .js and .ts files.

proc getCount*(e: ptr Event): csize_t {.webui, importc: "webui_get_count".}
  ##  Get how many arguments there are in an event.

proc getIntAt*(e: ptr Event; index: csize_t): clonglong {.webui, importc: "webui_get_int_at".}
  ##  Get an argument as integer at a specific index

proc getInt*(e: ptr Event): clonglong {.webui, importc: "webui_get_int".}
  ##  Get the first argument as integer

proc getFloatAt*(e: ptr Event; index: csize_t): cdouble {.webui, importc: "webui_get_float_at".}
  ##  Get an argument as float at a specific index

proc getFloat*(e: ptr Event): cdouble {.webui, importc: "webui_get_float".}
  ##  Get the first argument as float

proc getStringAt*(e: ptr Event; index: csize_t): cstring {.webui, importc: "webui_get_string_at".}
  ##  Get an argument as string at a specific index

proc getString*(e: ptr Event): cstring {.webui, importc: "webui_get_string".}
  ##  Get the first argument as string

proc getBoolAt*(e: ptr Event; index: csize_t): csize_t {.webui, importc: "webui_get_bool_at".}
  ##  Get an argument as boolean at a specific index

proc getBool*(e: ptr Event): csize_t {.webui, importc: "webui_get_bool".}
  ##  Get the first argument as boolean

proc getSizeAt*(e: ptr Event; index: csize_t): csize_t {.webui, importc: "webui_get_size_at".}
  ##  Get the size in bytes of an argument at a specific index

proc getSize*(e: ptr Event): csize_t {.webui, importc: "webui_get_size".}
  ##  Get size in bytes of the first argument

proc returnInt*(e: ptr Event; n: clonglong) {.webui, importc: "webui_return_int".}
  ##  Return the response to JavaScript as integer.

proc returnFloat*(e: ptr Event; f: cdouble) {.webui, importc: "webui_return_float".}
  ##  Return the response to JavaScript as integer.

proc returnString*(e: ptr Event; s: cstring) {.webui, importc: "webui_return_string".}
  ##  Return the response to JavaScript as string.

proc returnBool*(e: ptr Event; b: bool) {.webui, importc: "webui_return_bool".}
  ##  Return the response to JavaScript as boolean.

#  -- Interface -----------------------

proc interfaceBind*(window: csize_t; element: cstring; `func`: proc (window: csize_t; eventType: csize_t;
    element: cstring; eventNumber: csize_t; bindId: csize_t) {.cdecl.}): csize_t {.webui,
    importc: "webui_interface_bind".}
  ##  Bind a specific HTML element click event with a function. Empty element means all events.
  ##
  ##  :func: The callback as myFunc(Window, EventType, Element, EventNumber, BindID)

proc interfaceSetResponse*(window: csize_t; event_number: csize_t; repsonse: cstring) {.webui,
    importc: "webui_interface_set_response".}
  ##  When using `interfaceBind()`, you may need this function to easily set a response.

proc interfaceIsAppRunning*(): bool {.webui, importc: "webui_interface_is_app_running".}
  ##  Check if the app still running or not. This replace `wait()`.

proc interfaceGetWindowId*(window: csize_t): csize_t {.webui, importc: "webui_interface_get_window_id".}
  ##  Get a unique window ID.

proc interfaceGetIntAt*(window: csize_t; event_number: csize_t; index: csize_t): clonglong {.webui,
    importc: "webui_interface_get_int_at".}
  ##  Get an argument as integer at a specific index

proc interfaceGetStringAt*(window: csize_t; event_number: csize_t; index: csize_t): cstring {.webui,
    importc: "webui_interface_get_string_at".}
  ##  Get an argument as string at a specific index

proc interfaceGetBoolAt*(window: csize_t; event_number: csize_t; index: csize_t): bool {.webui,
    importc: "webui_interface_get_bool_at".}
  ##  Get an argument as boolean at a specific index

proc interfaceGetSizeAt*(window: csize_t; event_number: csize_t; index: csize_t): csize_t {.webui,
    importc: "webui_interface_get_size_at".}
  ##  Get the size in bytes of an argument at a specific index
