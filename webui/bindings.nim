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

const
  WEBUI_VERSION* = "2.5.0-Beta.2" ## Version
  WEBUI_MAX_IDS* = (256)
  WEBUI_MAX_ARG* = (16)

# -- Types -------------------------

type
  WebuiBrowser* = enum
    wbNoBrowser     ## 0. No web browser
    wbAny           ## 1. Default recommended web browser
    wbChrome        ## 2. Google Chrome
    wbFirefox       ## 3. Mozilla Firefox
    wbEdge          ## 4. Microsoft Edge
    wbSafari        ## 5. Apple Safari
    wbChromium      ## 6. The Chromium Project
    wbOpera         ## 7. Opera Browser
    wbBrave         ## 8. The Brave Browser
    wbVivaldi       ## 9. The Vivaldi Browser
    wbEpic          ## 10. The Epic Browser
    wbYandex        ## 11. The Yandex Browser
    wbChromiumBased ## 12. Any Chromium based browser
    wbWebview       ## 13. Webview (not a web browser)

  WebuiRuntime* = enum
    wrNone   ## 0. Prevent WebUI from using any runtime for .js and .ts files
    wrDeno   ## 1. Use Deno runtime for .js and .ts files
    wrNodeJs ## 2. Use Nodejs runtime for .js files

  WebuiEvent* = enum
    weDisconnected       ## 0. Window disconnection event
    weConnected          ## 1. Window connection event
    weMultiConnection    ## 2. New window connection event
    weUnwantedConnection ## 3. New unwanted window connection event
    weMouseClick         ## 4. Mouse click event
    weNavigation         ## 5. Window navigation event
    weCallback           ## 6. Function call event

  WebuiConfig* = enum
    wcShowWaitConnection
      ## Control if `show()` and `showX()` (e.g. `showBrowser()` & `showWv`)
      ## should wait for the window to connect before returns or not.
      ## 
      ## Default: `true`
    wcUiEventBlocking
      ## Control if WebUI should block and process the UI events one a time in
      ## a single thread (`true`), or process every event in a new non-blocking
      ## thread (`false`). This updates all windows. You can use
      ## `setEventBlocking()` for a specific single window update.
      ## 
      ## Default: `false`
    wcFolderMonitor
      ## Automatically refresh the window UI when any file in the root folder
      ## changes
      ## 
      ## Default: `false`
    wcMultiClient
      ## Allow multiple clients to connect to the same window. This is helpful
      ## for web apps (non-desktop software). Please see the documentation for
      ## more details.
      ## 
      ## Default: `false`

  Event* {.bycopy.} = object
    window*: csize_t      ## The window object number
    eventType*: csize_t   ## Event type
    element*: cstring     ## HTML element ID
    eventNumber*: csize_t ## Internal WebUI
    bindId*: csize_t      ## Bind ID
    clientId*: csize_t    ## Client unique ID

# aliases to reduce breaking changes
const
  NoBrowser* {.deprecated.} = wbNoBrowser
  Any* {.deprecated.} = wbAny
  Chrome* {.deprecated.} = wbChrome
  Firefox* {.deprecated.} = wbFirefox
  Edge* {.deprecated.} = wbEdge
  Safari* {.deprecated.} = wbSafari
  Chromium* {.deprecated.} = wbChromium
  Opera* {.deprecated.} = wbOpera
  Brave* {.deprecated.} = wbBrave
  Vivaldi* {.deprecated.} = wbVivaldi
  Epic* {.deprecated.} = wbEpic
  Yandex* {.deprecated.} = wbYandex
  ChromiumBased* {.deprecated.} = wbChromiumBased

  None* {.deprecated.} = wrNone
  Deno* {.deprecated.} = wrDeno
  NodeJs* {.deprecated.} = wrNodeJs

  EventsDisconnected* {.deprecated.} = weDisconnected
  EventsConnected* {.deprecated.} = weConnected
  EventsMultiConnection* {.deprecated.} = weMultiConnection
  EventsUnwantedConnection* {.deprecated.} = weUnwantedConnection
  EventsMouseClick* {.deprecated.} = weMouseClick
  EventsNavigation* {.deprecated.} = weNavigation
  EventsCallback* {.deprecated.} = weCallback

#  -- Definitions ---------------------

proc newWindow*(): csize_t {.webui, importc: "webui_new_window".}
  ##  Create a new WebUI window object.

proc newWindowId*(windowNumber: csize_t): csize_t {.webui, importc: "webui_new_window_id".}
  ##  Create a new webui window object using a specified window number.

proc getNewWindowId*(): csize_t {.webui, importc: "webui_get_new_window_id".}
  ##  Get a free window number that can be used with `newWindowId()`

proc `bind`*(window: csize_t; element: cstring; `func`: proc (e: ptr Event) {.cdecl.}): csize_t {.webui,
    importc: "webui_bind".}
  ##  Bind an HTML element and a JavaScript object with a backend function.
  ##  Empty `element` means all events.

proc getBestBrowser*(window: csize_t): csize_t {.webui, importc: "webui_get_best_browser".}
  ##  Get the "best" browser to be used. If running `show()` or passing
  ##  `wbAnyBrowser` to `showBrowser()`, this function will return the same
  ##  browser that will be used.

proc show*(window: csize_t; content: cstring): bool {.webui, importc: "webui_show".}
  ##  Show a window using embedded HTML, or a file. If the window is already
  ##  open, it will be refreshed. This will refresh all windows in multi-client
  ##  mode.

proc showClient*(e: ptr Event; content: cstring): bool {.webui, importc: "webui_show_client".}
  ##  Show a window using embedded HTML, or a file. If the window is already
  ##  open, it will be refreshed. Single client.

proc showBrowser*(window: csize_t; content: cstring; browser: csize_t): bool {.webui, importc: "webui_show_browser".}
  ##  Same as `show()`, but using a specific web browser.

proc startServer*(window: csize_t; path: cstring): cstring {.webui, importc: "webui_start_server".}
  ##  Start only the web server and return the URL. This is useful for web app.

proc showWv*(window: csize_t; content: cstring): bool {.webui, importc: "webui_show_wv".}
  ##  Show a WebView window using embedded HTML, or a file. If the window is
  ##  already open, it will be refreshed.
  ##  
  ##  .. note:: Windows needs `WebView2Loader.dll`.

proc setKiosk*(window: csize_t; status: bool) {.webui, importc: "webui_set_kiosk".}
  ##  Set the window in Kiosk mode (Full screen).

proc setHighContrast*(window: csize_t; status: bool) {.webui, importc: "webui_set_high_contrast".}
  ##  Setup the window with high-contrast support. Useful when you want to 
  ##  build a better high-contrast theme with CSS.

proc isHighContrast*(): bool {.webui, importc: "webui_is_high_contrast".}
  ##  Get the OS's high contrast preference.

proc browserExist*(browser: WebuiBrowser): bool {.webui, importc: "webui_browser_exist".}
  ##  Check if a web browser is installed.

proc wait*() {.webui, importc: "webui_wait".}
  ##  Wait until all opened windows get closed.

proc close*(window: csize_t) {.webui, importc: "webui_close".}
  ##  Close a specific window only. The window object will still exist. All
  ##  clients.

proc closeClient*(e: ptr Event) {.webui, importc: "webui_close_client".}
  ##  Close a specific client.

proc destroy*(window: csize_t) {.webui, importc: "webui_destroy".}
  ##  Close a specific window and free all memory resources.

proc exit*() {.webui, importc: "webui_exit".}
  ##  Close all open windows. `wait()` will return (Break).

proc setRootFolder*(window: csize_t; path: cstring): bool {.webui, importc: "webui_set_root_folder".}
  ##  Set the web-server root folder path for a specific window.

proc setDefaultRootFolder*(path: cstring): bool {.webui, importc: "webui_default_set_root_folder".}
  ##  Set the web-server root folder path for all windows. Should be used
  ##  before `show()`.

proc setFileHandler*(window: csize_t; handler: proc (filename: cstring; length: ptr cint): pointer {.cdecl.}) {.webui,
    importc: "webui_set_file_handler".}
  ##  Set a custom handler to serve files.

proc isShown*(window: csize_t): bool {.webui, importc: "webui_is_shown".}
  ##  Check if the specified winFdow is still running.

proc setTimeout*(second: csize_t) {.webui, importc: "webui_set_timeout".}
  ##  Set the maximum time in seconds to wait for the window to connect. This
  ##  will affect `show()` and `wait()`. Setting the timeout to `0` will cause
  ##  WebUI to wait forever.

proc setIcon*(window: csize_t; icon: cstring; `type`: cstring) {.webui, importc: "webui_set_icon".}
  ##  Set the default embedded HTML favicon.

proc encode*(str: cstring): cstring {.webui, importc: "webui_encode".}
  ##  Encode text to Base64 encoding. Use this to safely send text based data
  ##  to the UI. If it fails it will return `nil`. The returned buffer must be
  ##  freed.

proc decode*(str: cstring): cstring {.webui, importc: "webui_decode".}
  ##  Decode a Base64 encoded text. Use this to safely decode received Base64
  ##  text from the UI. If it fails it will return `nil`. The returned buffer
  ##  must be freed.

proc free*(`ptr`: pointer) {.webui, importc: "webui_free".}
  ##  Safely free a buffer allocated by WebUI using `malloc()`.

proc malloc*(size: csize_t): pointer {.webui, importc: "webui_malloc".}
  ##  Safely allocate memory using the WebUI memory management system. It
  ##  can be safely freed using `free()` at any time.

proc sendRaw*(window: csize_t; function: cstring; raw: pointer; size: csize_t) {.webui, importc: "webui_send_raw".}
  ##  Safely send raw data to the UI. All clients.

proc sendRawClient*(e: ptr Event; function: cstring; raw: pointer; size: csize_t) {.webui, importc: "webui_send_raw_client".}
  ##  Safely send raw data to the UI. Single client.

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
  ##  Set the web browser to use `proxy_server`. Must be called before
  ##  `show()`.

proc getUrl*(window: csize_t): cstring {.webui, importc: "webui_get_url".}
  ##  Get current URL of a running window.

proc setPublic*(window: csize_t; status: bool) {.webui, importc: "webui_set_public".}
  ##  Allow a specific window address to be accessible from a public network.

proc navigate*(window: csize_t; url: cstring) {.webui, importc: "webui_navigate".}
  ##  Navigate to a specific URL. All clients.

proc navigateClient*(e: ptr Event; url: cstring) {.webui, importc: "webui_navigate_client".}
  ##  Navigate to a specific URL. Single client.

proc clean*() {.webui, importc: "webui_clean".}
  ##  Free all memory resources. Should be called only at the end.

proc deleteAllProfiles*() {.webui, importc: "webui_delete_all_profiles".}
  ##  Delete all local web-browser profiles folder. It should be called at the
  ##  end.

proc deleteProfile*(window: csize_t) {.webui, importc: "webui_delete_profile".}
  ##  Delete a specific window web-browser local folder profile.

proc getParentProcessId*(window: csize_t): csize_t {.webui, importc: "webui_get_parent_process_id".}
  ##  Get the ID of the parent process (The web browser may re-create
  ##  another new process).

proc getChildProcessId*(window: csize_t): csize_t {.webui, importc: "webui_get_child_process_id".}
  ##  Get the ID of the last child process.

proc setPort*(window: csize_t; port: csize_t): bool {.webui, importc: "webui_set_port", discardable.}
  ##  Set a custom web-server/websocket network port to be used by WebUI. This
  ##  can be useful to determine the HTTP link of `webui.js` in case you are
  ##  trying to use WebUI with an external web-server like NGNIX.

proc setConfig*(option: WebuiConfig; status: bool) {.webui, importc: "webui_set_config".}
  ## Control WebUI's behaviour. It's recommended to call this at the beginning.

proc setEventBlocking*(window: csize_t; status: bool) {.webui, importc: "webui_set_event_blocking".}
  ##  Control if UI events comming from this window should be processed
  ##  one a time in a single blocking thread (`true`), or process every event
  ##  in a new non-blocking thread (`false`). This function only updates a
  ##  single window. You can use `setConfig(wcUiEventBlocking, ...)` to update
  ##  all windows.

# -- SSL/TLS -------------------------

proc setTlsCertificate*(certificate_pem: cstring; private_key_pem: cstring): bool {.webui, importc: "webui_set_tls_certificate".}
  ##  Set the SSL/TLS certificate and the private key content, both in PEM
  ##  format. This works only with `webui-2-secure` library. If set empty WebUI
  ##  will generate a self-signed certificate.

# -- JavaScript ----------------------

proc run*(window: csize_t; script: cstring) {.webui, importc: "webui_run".}
  ##  Run JavaScript without waiting for the response. All clients.

proc runClient*(e: ptr Event; script: cstring) {.webui, importc: "webui_run_client".}
  ##  Run JavaScript without waiting for the response. Single client.

proc script*(window: csize_t; script: cstring; timeout: csize_t; buffer: cstring; bufferLength: csize_t): bool {.webui, importc: "webui_script".}
  ##  Run JavaScript and get the response back. Make sure your local buffer can
  ##  hold the response. All clients.

proc scriptClient*(e: ptr Event; script: cstring; timeout: csize_t; buffer: cstring; bufferLength: csize_t): bool {.webui, importc: "webui_script_client".}
  ##  Run JavaScript and get the response back. Make sure your local buffer can
  ##  hold the response. Single client.

proc setRuntime*(window: csize_t; runtime: csize_t) {.webui, importc: "webui_set_runtime".}
  ##  Chose between Deno and Nodejs as runtime for .js and .ts files.

proc getCount*(e: ptr Event): csize_t {.webui, importc: "webui_get_count".}
  ##  Get how many arguments there are in an event.

proc getIntAt*(e: ptr Event; index: csize_t): clonglong {.webui, importc: "webui_get_int_at".}
  ##  Get an argument as integer at a specific index.

proc getInt*(e: ptr Event): clonglong {.webui, importc: "webui_get_int".}
  ##  Get the first argument as integer.

proc getFloatAt*(e: ptr Event; index: csize_t): cdouble {.webui, importc: "webui_get_float_at".}
  ##  Get an argument as float at a specific index.

proc getFloat*(e: ptr Event): cdouble {.webui, importc: "webui_get_float".}
  ##  Get the first argument as float.

proc getStringAt*(e: ptr Event; index: csize_t): cstring {.webui, importc: "webui_get_string_at".}
  ##  Get an argument as string at a specific index.

proc getString*(e: ptr Event): cstring {.webui, importc: "webui_get_string".}
  ##  Get the first argument as string.

proc getBoolAt*(e: ptr Event; index: csize_t): csize_t {.webui, importc: "webui_get_bool_at".}
  ##  Get an argument as boolean at a specific index.

proc getBool*(e: ptr Event): csize_t {.webui, importc: "webui_get_bool".}
  ##  Get the first argument as boolean.

proc getSizeAt*(e: ptr Event; index: csize_t): csize_t {.webui, importc: "webui_get_size_at".}
  ##  Get the size in bytes of an argument at a specific index.

proc getSize*(e: ptr Event): csize_t {.webui, importc: "webui_get_size".}
  ##  Get size in bytes of the first argument.

proc returnInt*(e: ptr Event; n: clonglong) {.webui, importc: "webui_return_int".}
  ##  Return the response to JavaScript as integer.

proc returnFloat*(e: ptr Event; f: cdouble) {.webui, importc: "webui_return_float".}
  ##  Return the response to JavaScript as integer.

proc returnString*(e: ptr Event; s: cstring) {.webui, importc: "webui_return_string".}
  ##  Return the response to JavaScript as string.

proc returnBool*(e: ptr Event; b: bool) {.webui, importc: "webui_return_bool".}
  ##  Return the response to JavaScript as boolean.

#  -- Interface -----------------------

proc interfaceBind*(window: csize_t; element: cstring; `func`: proc (window: csize_t; eventType: csize_t; element: cstring; eventNumber: csize_t; bindId: csize_t) {.cdecl.}): csize_t {.webui, importc: "webui_interface_bind".}
  ##  Bind a specific HTML element click event with a function. Empty element
  ##  means all events.
  ##  
  ##  :func: The callback as `myFunc(Window, EventType, Element, EventNumber, BindID)`

proc interfaceSetResponse*(window: csize_t; event_number: csize_t; repsonse: cstring) {.webui, importc: "webui_interface_set_response".}
  ##  When using `interfaceBind()`, you may need this function to easily set a
  ##  response.

proc interfaceIsAppRunning*(): bool {.webui, importc: "webui_interface_is_app_running".}
  ##  Check if the app still running or not. This replaces `wait()`.

proc interfaceGetWindowId*(window: csize_t): csize_t {.webui, importc: "webui_interface_get_window_id".}
  ##  Get a unique window ID.

proc interfaceGetIntAt*(window: csize_t; event_number: csize_t; index: csize_t): clonglong {.webui, importc: "webui_interface_get_int_at".}
  ##  Get an argument as an integer at a specific index.

proc interfaceGetFloatAt*(window: csize_t; event_number: csize_t; index: csize_t): cdouble {.webui, importc: "webui_interface_get_float_at".}
  ##  Get an argument as a float at a specific index.

proc interfaceGetStringAt*(window: csize_t; event_number: csize_t; index: csize_t): cstring {.webui, importc: "webui_interface_get_string_at".}
  ##  Get an argument as a string at a specific index.

proc interfaceGetBoolAt*(window: csize_t; event_number: csize_t; index: csize_t): bool {.webui, importc: "webui_interface_get_bool_at".}
  ##  Get an argument as a boolean at a specific index.

proc interfaceGetSizeAt*(window: csize_t; event_number: csize_t; index: csize_t): csize_t {.webui, importc: "webui_interface_get_size_at".}
  ##  Get the size in bytes of an argument at a specific index.
