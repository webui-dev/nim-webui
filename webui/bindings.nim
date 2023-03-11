import std/os

const
  currentSourceDir = currentSourcePath().parentDir()

when defined(useWebuiStaticLib) or defined(useWebuiStaticLibrary):
  when defined(vcc):
    {.link: "user32.lib".}
    {.link: "ws2_32.lib".}

    {.link: "webui-2-static-x64.lib".}
  else:
    {.passL: "-L.".}

    {.passL: "-lwebui-2-static-x64".}

    {.passL: "-luser32".}
    {.passL: "-lws2_32".}

  {.pragma: webui.}
elif defined(useWebuiDll):
  const webuiDll* = when defined(windows):
    "webui-2-x64.dll"
  elif defined(macos):
    "webui-2-x64.dynlib"
  else:
    "webui-2-x64.so"

  {.pragma: webui, dynlib: webuiDll.}
else:
  when defined(vcc):
    {.link: "user32.lib".}
    {.link: "ws2_32.lib".}

    {.passC: "/I " & currentSourceDir / "webui" / "include".}

  elif defined(windows):
    {.passL: "-lws2_32".}
    {.passL: "-luser32".}

    {.passL: "-static".}

    {.passC: "-I" & currentSourceDir / "webui" / "include".}

  when defined(linux):
    {.passL: "-lpthread".}
    {.passL: "-lm".}

    {.passL: "-static".}

    {.passC: "-I" & currentSourceDir / "webui" / "include".}

  {.pragma: webui.}

  {.compile: "./webui/src/mongoose.c".}
  {.compile: "./webui/src/webui.c".}

const
  WEBUI_VERSION* = "2.0.6"
  WEBUI_HEADER_SIGNATURE* = 0xFF
  WEBUI_HEADER_JS* = 0xFE
  WEBUI_HEADER_CLICK* = 0xFD
  WEBUI_HEADER_SWITCH* = 0xFC
  WEBUI_HEADER_CLOSE* = 0xFB
  WEBUI_HEADER_CALL_FUNC* = 0xFA
  WEBUI_MAX_ARRAY* = (1024)
  WEBUI_MIN_PORT* = (10000)
  WEBUI_MAX_PORT* = (65500)
  WEBUI_MAX_BUF* = (1024000)
  WEBUI_DEFAULT_PATH* = "."
  WEBUI_DEF_TIMEOUT* = (8)

type
  #Timer* {.bycopy.} = object
  #  start*: Timespec
  #  now*: Timespec

  WindowCore* {.bycopy.} = object
    windowNumber*: cuint
    serverRunning*: bool
    connected*: bool
    serverHandled*: bool
    multiAccess*: bool
    serverRoot*: bool
    serverPort*: cuint
    isBindAll*: bool
    url*: cstring
    html*: cstring
    htmlCpy*: cstring
    icon*: cstring
    iconType*: cstring
    currentBrowser*: cuint
    browserPath*: cstring
    profilePath*: cstring
    connections*: cuint
    runtime*: cuint
    detectProcessClose*: bool
    #when defined(windows):
    #  serverThread: Handle
    #else:
    #  serverThread: PthreadT

  Window* {.bycopy.} = object
    core*: WindowCore
    path*: cstring

  Event* {.bycopy.} = object
    windowId*: cuint
    elementId*: cuint
    elementName*: cstring
    window*: ptr Window
    data*: pointer
    response*: pointer

  JavascriptResult* {.bycopy.} = object
    error*: bool
    length*: cuint
    data*: cstring

  Script* {.bycopy.} = object
    script*: cstring
    timeout*: cuint
    result*: JavascriptResult

  Cb* {.bycopy.} = object
    win*: ptr Window
    internalId*: cstring
    elementName*: cstring
    data*: pointer

  CmdAsync* {.bycopy.} = object
    win*: ptr Window
    cmd*: cstring

  CustomBrowser* {.bycopy.} = object
    app*: cstring
    arg*: cstring
    autoLink*: bool

  Browser* {.bycopy.} = object
    `any`*: cuint
    chrome*: cuint
    firefox*: cuint
    edge*: cuint
    safari*: cuint
    chromium*: cuint
    custom*: cuint

  Runtime* {.bycopy.} = object
    none*: cuint
    deno*: cuint
    nodejs*: cuint

  Webui* {.bycopy.} = object
    servers*: cuint
    connections*: cuint
    process*: cuint
    customBrowser*: ptr CustomBrowser
    waitForSocketWindow*: bool
    htmlElements*: array[WEBUI_MAX_ARRAY, cstring]
    usedPorts*: array[WEBUI_MAX_ARRAY, cuint]
    lastWindow*: cuint
    startupTimeout*: cuint
    useTimeout*: bool
    timeoutExtra*: bool
    exitNow*: bool
    runResponses*: array[WEBUI_MAX_ARRAY, cstring]
    runDone*: array[WEBUI_MAX_ARRAY, bool]
    runError*: array[WEBUI_MAX_ARRAY, bool]
    runLastId*: cuint
    #mgMgrs*: array[WEBUI_MAX_ARRAY, ptr MgMgr]
    #mgConnections*: array[WEBUI_MAX_ARRAY, ptr MgConnection]
    browser*: Browser
    runtime*: Runtime
    initialized*: bool
    cb*: array[WEBUI_MAX_ARRAY, proc (e: ptr Event) {.cdecl.}]
    cb_interface*: array[WEBUI_MAX_ARRAY, proc (a1, a2: cuint; a3: cstring; a4: ptr Window; a5: cstring; a6: cstringArray) {.cdecl.}]
    cb_interface_all*: array[1, proc(a1, a2: cuint; a3: cstring; a4: ptr Window; a5: cstring; a6: cstringArray) {.cdecl.}]
    executablePath*: cstring
    ptrList*: array[WEBUI_MAX_ARRAY, pointer]
    ptrPosition*: cuint
    ptrSize*: array[WEBUI_MAX_ARRAY, csize_t]

var webui*: Webui

proc wait*() {.cdecl, importc: "webui_wait", webui.}
proc exit*() {.cdecl, importc: "webui_exit", webui.}
proc isAnyWindowRunning*(): bool {.cdecl, importc: "webui_is_any_window_running", webui.}
proc isAppRunning*(): bool {.cdecl, importc: "webui_is_app_running", webui.}
proc setTimeout*(second: cuint) {.cdecl, importc: "webui_set_timeout", webui.}
proc newWindow*(): ptr Window {.cdecl, importc: "webui_new_window", webui.}
proc show*(win: ptr Window; html: cstring; browser: cuint): bool {.cdecl,
    importc: "webui_show", webui.}
proc showCpy*(win: ptr Window; html: cstring; browser: cuint): bool {.cdecl,
    importc: "webui_show_cpy", webui.}
proc refresh*(win: ptr Window; html: cstring): bool {.cdecl, importc: "webui_refresh", webui.}
proc refreshCpy*(win: ptr Window; html: cstring): bool {.cdecl,
    importc: "webui_refresh_cpy", webui.}
proc setIcon*(win: ptr Window; iconS: cstring; typeS: cstring) {.cdecl,
    importc: "webui_set_icon", webui.}
proc multiAccess*(win: ptr Window; status: bool) {.cdecl,
    importc: "webui_multi_access", webui.}
proc newServer*(win: ptr Window; path: cstring): cstring {.cdecl,
    importc: "webui_new_server", webui.}
proc close*(win: ptr Window) {.cdecl, importc: "webui_close", webui.}
proc isShown*(win: ptr Window): bool {.cdecl, importc: "webui_is_shown", webui.}
proc script*(win: ptr Window; script: ptr Script) {.cdecl, importc: "webui_script", webui.}
proc `bind`*(win: ptr Window; element: cstring; `func`: proc (e: ptr Event) {.cdecl.}): cuint {.
    cdecl, importc: "webui_bind", webui.}
proc bindAll*(win: ptr Window; `func`: proc (e: ptr Event) {.cdecl.}) {.cdecl,
    importc: "webui_bind_all", webui.}
proc open*(win: ptr Window; url: cstring; browser: cuint): bool {.cdecl,
    importc: "webui_open", webui.}
proc scriptCleanup*(script: ptr Script) {.cdecl, importc: "webui_script_cleanup", webui.}
proc scriptRuntime*(win: ptr Window; runtime: cuint) {.cdecl,
    importc: "webui_script_runtime", webui.}
proc getInt*(e: ptr Event): cint {.cdecl, importc: "webui_get_int", webui.}
proc getString*(e: ptr Event): cstring {.cdecl, importc: "webui_get_string", webui.}
proc getBool*(e: ptr Event): bool {.cdecl, importc: "webui_get_bool", webui.}
proc returnInt*(e: ptr Event; n: cint) {.cdecl, importc: "webui_return_int", webui.}
proc returnString*(e: ptr Event; s: cstring) {.cdecl, importc: "webui_return_string", webui.}
proc returnBool*(e: ptr Event; b: bool) {.cdecl, importc: "webui_return_bool", webui.}

type
  ScriptInterface* {.bycopy.} = object
    script*: cstring
    timeout*: cuint
    error*: bool
    length*: cuint
    data*: cstring

proc bindInterface*(win: ptr Window; element: cstring; `func`: proc (a1: cuint;
    a2: cuint; a3: cstring; a4: ptr Window; a5: cstring; a6: cstringArray) {.cdecl.}): cuint {.
    cdecl, importc: "webui_bind_interface", webui.}
proc scriptInterface*(win: ptr Window; script: cstring; timeout: cuint;
                     error: ptr bool; length: ptr cuint; data: cstring) {.cdecl,
    importc: "webui_script_interface", webui.}
proc scriptInterfaceStruct*(win: ptr Window; jsInt: ptr ScriptInterface) {.cdecl,
    importc: "webui_script_interface_struct", webui.}

proc init*() {.cdecl, importc: "_webui_init", webui.}
proc getCbIndex*(internalId: cstring): cuint {.cdecl,
    importc: "_webui_get_cb_index", webui.}
proc setCbIndex*(internalId: cstring): cuint {.cdecl,
    importc: "_webui_set_cb_index", webui.}
proc getFreePort*(): cuint {.cdecl, importc: "_webui_get_free_port", webui.}
proc getNewWindowNumber*(): cuint {.cdecl,
                                      importc: "_webui_get_new_window_number", webui.}
proc waitForStartup*() {.cdecl, importc: "_webui_wait_for_startup", webui.}
proc freePort*(port: cuint) {.cdecl, importc: "_webui_free_port", webui.}
proc setCustomBrowser*(p: ptr CustomBrowser) {.cdecl,
    importc: "_webui_set_custom_browser", webui.}
proc getCurrentPath*(): cstring {.cdecl, importc: "_webui_get_current_path", webui.}
proc windowReceive*(win: ptr Window; packet: cstring; len: csize_t) {.cdecl,
    importc: "_webui_window_receive", webui.}
proc windowSend*(win: ptr Window; packet: cstring; packetsSize: csize_t) {.cdecl,
    importc: "_webui_window_send", webui.}
proc windowEvent*(win: ptr Window; elementId: cstring; element: cstring;
                      data: pointer; dataLen: cuint) {.cdecl,
    importc: "_webui_window_event", webui.}
proc windowGetNumber*(win: ptr Window): cuint {.cdecl,
    importc: "_webui_window_get_number", webui.}
proc windowOpen*(win: ptr Window; link: cstring; browser: cuint) {.cdecl,
    importc: "_webui_window_open", webui.}
proc cmdSync*(cmd: cstring; show: bool): cint {.cdecl, importc: "_webui_cmd_sync", webui.}
proc cmdAsync*(cmd: cstring; show: bool): cint {.cdecl,
    importc: "_webui_cmd_async", webui.}
proc runBrowser*(win: ptr Window; cmd: cstring): cint {.cdecl,
    importc: "_webui_run_browser", webui.}
proc clean*() {.cdecl, importc: "_webui_clean", webui.}
proc browserExist*(win: ptr Window; browser: cuint): bool {.cdecl,
    importc: "_webui_browser_exist", webui.}
proc browserGetTempPath*(browser: cuint): cstring {.cdecl,
    importc: "_webui_browser_get_temp_path", webui.}
proc folderExist*(folder: cstring): bool {.cdecl, importc: "_webui_folder_exist", webui.}
proc browserCreateProfileFolder*(win: ptr Window; browser: cuint): bool {.cdecl,
    importc: "_webui_browser_create_profile_folder", webui.}
proc browserStartEdge*(win: ptr Window; address: cstring): bool {.cdecl,
    importc: "_webui_browser_start_edge", webui.}
proc browserStartFirefox*(win: ptr Window; address: cstring): bool {.cdecl,
    importc: "_webui_browser_start_firefox", webui.}
proc browserStartCustom*(win: ptr Window; address: cstring): bool {.cdecl,
    importc: "_webui_browser_start_custom", webui.}
proc browserStartChrome*(win: ptr Window; address: cstring): bool {.cdecl,
    importc: "_webui_browser_start_chrome", webui.}
proc browserStart*(win: ptr Window; address: cstring; browser: cuint): bool {.
    cdecl, importc: "_webui_browser_start", webui.}
#proc webuiTimerDiff*(start: ptr Timespec; `end`: ptr Timespec): clong {.cdecl,
#    importc: "_webui_timer_diff", webui.}
#proc webuiTimerStart*(t: ptr Timer) {.cdecl, importc: "_webui_timer_start", webui.}
#proc webuiTimerIsEnd*(t: ptr Timer; ms: cuint): bool {.cdecl,
#    importc: "_webui_timer_is_end", webui.}
#proc webuiTimerClockGettime*(spec: ptr Timespec) {.cdecl,
#    importc: "_webui_timer_clock_gettime", webui.}
proc setRootFolder*(win: ptr Window; path: cstring): bool {.cdecl,
    importc: "_webui_set_root_folder", webui.}
proc waitProcess*(win: ptr Window; status: bool) {.cdecl,
    importc: "_webui_wait_process", webui.}
proc generateJsBridge*(win: ptr Window): cstring {.cdecl,
    importc: "_webui_generate_js_bridge", webui.}
proc printHex*(data: cstring; len: csize_t) {.cdecl, importc: "_webui_print_hex", webui.}
proc freeMem*(p: ptr pointer) {.cdecl, importc: "_webui_free_mem", webui.}
proc strCopy*(destination: cstring; source: cstring) {.cdecl,
    importc: "_webui_str_copy", webui.}
proc fileExistMg*(evData: pointer): bool {.cdecl,
    importc: "_webui_file_exist_mg", webui.}
proc fileExist*(file: cstring): bool {.cdecl, importc: "_webui_file_exist", webui.}