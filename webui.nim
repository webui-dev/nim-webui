from webui/bindings import nil

type
  #Timer* {.bycopy.} = object
  #  start*: Timespec
  #  now*: Timespec

  WindowCore* = ref object
    internalImpl: bindings.WindowCore

  Window* = ref object
    internalImpl: pointer

  Event* = ref object
    ## When you use `bind()`, your application will receive an event every time 
    ## the user clicks on the specified HTML element. The event comes with the 
    ## `element_name`, which is The HTML ID of the clicked element, for example,
    ## `MyButton`, `MyInput`.., The event also comes with the WebUI unique element 
    ## ID & the unique window ID.
  
    internalImpl: pointer

  JavascriptResult* = ref object
    error*: bool
    length*: int
    data*: string

  Script* = ref object
    internalImpl: bindings.Script

  CustomBrowser* = ref object
    internalImpl: bindings.CustomBrowser

  Browser* = enum
    BrowserAny = 0
    BrowserChrome = 1
    BrowserFirefox = 2
    BrowserEdge = 3
    BrowserSafari = 4
    BrowserChromium = 5
    BrowserCustom = 99

  Runtime* = enum
    RuntimeNone
    RuntimeDeno
    RuntimeNodeJs

proc wait*() =
  ## Run application run until the user closes all 
  ## visible windows or when calling `exit() <#exit>`_

  bindings.wait()

proc exit*() = 
  ## Try and close all related opened windows and make `wait() <#wait>`_ break.

  bindings.exit()

proc isAnyWindowRunning*(): bool =
  ## Return if any opened window exists
  
  bindings.isAnyWindowRunning()

proc isAppRunning*(): bool =
  ## Return if the whole application still running or not
  
  bindings.isAppRunning()

proc setTimeout*(timeout: int) = 
  ## Waits `timeout` seconds to let the web browser start and connect.
  ## 
  ## Set `timeout` to `0` to wait forever.
  
  bindings.setTimeout(cuint timeout)

proc init*() =
  bindings.init()

proc getCbIndex*(internalId: string): int =
  int bindings.getCbIndex(cstring internalId)

proc setCbIndex*(internalId: string): int =
  int bindings.setCbIndex(cstring internalId)

proc getFreePort*(): int =
  int bindings.getFreePort()

proc getNewWindowNumber*(): int =
  int bindings.getNewWindowNumber()

proc waitForStartup*() =
  bindings.waitForStartup()

proc freePort*(port: int) =
  bindings.freePort(cuint port)

proc setCustomBrowser*(p: var CustomBrowser) =
  bindings.setCustomBrowser(addr p.internalImpl)

proc getCurrentPath*(): string =
  $ bindings.getCurrentPath()

proc cmdSync*(cmd: string; show: bool): int =
  int bindings.cmdSync(cstring cmd, show)

proc cmdAsync*(cmd: string; show: bool): int =
  int bindings.cmdAsync(cstring cmd, show)

proc clean*() =
  bindings.clean()

proc browserGetTempPath*(browser: Browser): string =
  $ bindings.browserGetTempPath(cuint ord(browser))

proc folderExist*(folder: string): bool =
  bindings.folderExist(cstring folder)

proc printHex*(data: string; len: int) =
  bindings.printHex(cstring data, csize_t len)

proc fileExist*(file: string): bool =
  bindings.fileExist(cstring file)

# SKIPPED: freeMem()
# SKIPPED: strCopy()
# SKIPPED: fileExistMg()

# above skipped functions seem unneccessary and too low-level

# ------- Impl funcs --------

# --- Event ---

func impl*(e: Event): ptr bindings.Event = 
  cast[ptr bindings.Event](e.internalImpl)

func `impl=`*(e: Event, be: ptr bindings.Event) = 
  e.internalImpl = pointer(be)

# --- WindowCore ---

func impl*(winCore: WindowCore): bindings.WindowCore = 
  winCore.internalImpl

func `impl=`*(winCore: WindowCore, bwinCore: bindings.WindowCore) = 
  winCore.internalImpl = bwinCore

# --- Window ---

func impl*(win: Window): ptr bindings.Window = 
  cast[ptr bindings.Window](win.internalImpl)

func `impl=`*(win: Window, bwin: ptr bindings.Window) = 
  win.internalImpl = pointer(bwin)

# -------- Script --------

proc newScript*(script: string; timeout: int): Script =
  result.internalImpl.script = cstring script
  result.internalImpl.timeout = cuint timeout

proc script*(s: Script): string =
  $ s.internalImpl.script

proc timeout*(s: Script): int =
  int s.internalImpl.timeout

proc result*(s: Script): JavascriptResult =
  new result

  result.error = s.internalImpl.result.error
  result.length = int s.internalImpl.result.length
  result.data = $ s.internalImpl.result.data

proc cleanup*(s: var Script) = 
  bindings.scriptCleanup(addr s.internalImpl)

# -------- Event --------

proc windowId*(e: Event): int =
  int e.impl.windowId

proc elementId*(e: Event): int =
  int e.impl.elementId

proc elementName*(e: Event): string =
  $ e.impl.elementName

proc window*(e: Event): Window =
  new result

  result.impl = e.impl.window

proc data*(e: Event): pointer =
  e.impl.data

proc response*(e: Event): pointer =
  e.impl.response

proc getInt*(e: Event): int =
  int bindings.getInt(e.impl)

proc getString*(e: Event): string =
  $ bindings.getString(e.impl)

proc getBool*(e: Event): bool =
  bindings.getBool(e.impl)

proc returnInt*(e: Event; n: int) = 
  bindings.returnInt(e.impl, cint n)

proc returnString*(e: Event; s: string) =
  bindings.returnString(e.impl, cstring s)

proc returnBool*(e: Event; b: bool) =
  bindings.returnBool(e.impl, b)

# -------- Window Core --------

proc windowNum*(winCore: WindowCore): int =
  int winCore.impl.windowNumber

proc serverRunning*(winCore: WindowCore): bool =
  bool winCore.impl.serverRunning

proc connected*(winCore: WindowCore): bool =
  bool winCore.impl.connected

proc multiAccess*(winCore: WindowCore): bool =
  bool winCore.impl.multiAccess

proc serverRoot*(winCore: WindowCore): bool =
  bool winCore.impl.serverRoot

proc serverPort*(winCore: WindowCore): int =
  int winCore.impl.serverPort

proc bindAll*(winCore: WindowCore): bool =
  bool winCore.impl.isBindAll

proc url*(winCore: WindowCore): string =
  $ winCore.impl.url

proc html*(winCore: WindowCore): string =
  $ winCore.impl.html

proc htmlCpy*(winCore: WindowCore): string =
  $ winCore.impl.htmlCpy

proc icon*(winCore: WindowCore): string =
  $ winCore.impl.icon

proc iconType*(winCore: WindowCore): string =
  $ winCore.impl.iconType

{.push warning[HoleEnumConv]: off.}
proc currentBrowser*(winCore: WindowCore): Browser =
  Browser(int winCore.impl.currentBrowser)
{.pop.}

proc browserPath*(winCore: WindowCore): string =
  $ winCore.impl.browserPath

proc profilePath*(winCore: WindowCore): string =
  $ winCore.impl.profilePath

proc connections*(winCore: WindowCore): int =
  int winCore.impl.connections

proc runtime*(winCore: WindowCore): int =
  int winCore.impl.runtime

proc detectProcessClose*(winCore: WindowCore): bool =
  winCore.impl.detectProcessClose

# -------- Window --------

proc newWindow*(): Window =
  ## Create new Window object

  new result

  result.impl = bindings.newWindow()

proc path*(win: Window): string =
  $win.impl.path

proc core*(win: Window): WindowCore =
  new result

  result.impl = win.impl.core

proc show*(win: Window; html: string; browser: Browser = BrowserAny) = 
  ## Show Window `win`. If the window is already shown, the UI will get 
  ## refreshed in the same window.

  discard bindings.show(win.impl, cstring html, cuint ord(browser))

proc showCopy*(win: Window; html: string; browser: Browser = BrowserAny) = 
  discard bindings.showCpy(win.impl, cstring html, cuint ord(browser))

proc refresh*(win: Window; html: string) = 
  ## Refresh the window UI with any new HTML content.

  discard bindings.refresh(win.impl, cstring html)

proc refreshCopy*(win: Window; html: string) = 
  discard bindings.refreshCpy(win.impl, cstring html)

proc `icon=`*(win: Window; iconS, typeS: string) = 
  bindings.setIcon(win.impl, cstring iconS, cstring typeS)

proc multiAccess*(win: Window; status: bool) = 
  ## After the window is loaded, for safety, the used URL is not valid anymore, 
  ## if someone else tries to access the URL WebUI will show an error.
  ## 
  ## `multiAccess` allows multi-user access to the same URL.

  bindings.multiAccess(win.impl, status)

proc newServer*(win: Window; path: string): string =
  ## Serve folder `path`.
  ## 
  ## Returns the complete URL of the server.
  
  $bindings.newServer(win.impl, cstring path)

proc close*(win: Window) = 
  ## Close window `win`. If there is no running window left, `wait() <#wait>`_ will break.
  bindings.close(win.impl)

proc shown*(win: Window): bool = 
  ## Return if window is still running

  bindings.isShown(win.impl)

proc script*(win: Window; script: var Script) =
  bindings.script(win.impl, addr script.internalImpl)

proc wrapBind(e: ptr bindings.Event) {.cdecl.} =
  let fun = cast[proc (e: Event) {.nimcall.}](bindings.webui.cb[^1])

  var event: Event
  new event

  event.impl = e

  fun(event)

proc `bind`*(win: Window; element: string; `func`: proc (e: Event) {.nimcall.}): int {.discardable.} =
  ## Receive click events when the user clicks on any HTML element with a specific ID
  
  int bindings.`bind`(win.impl, cstring element, wrapBind)

proc bindAll*(win: Window; `func`: proc (e: Event) {.nimcall.}): int {.discardable.} =
  ## Bind all elements
  bindings.bindAll(win.impl, wrapBind)

proc open*(win: Window; url: string; browser: Browser = BrowserAny) =
  discard bindings.open(win.impl, cstring url, cuint ord(browser))

proc scriptRuntime*(win: Window; runtime: Runtime) = 
  ## Make WebUI act like  runtime`runtime` (either NodeJS or Deno).
  ## 
  ## Useful when serving folders.
  
  bindings.scriptRuntime(win.impl, cuint ord(runtime))

proc receive*(win: Window; packet: string; len: int) =
  bindings.windowReceive(win.impl, cstring packet, csize_t len)

proc send*(win: Window; packet: string; packetsSize: int) =
  bindings.windowSend(win.impl, cstring packet, csize_t packetsSize)

proc event*(win: Window; elementId, element: string; data: pointer; dataLen: int) = 
  bindings.windowEvent(win.impl, cstring elementId, cstring element, data, cuint dataLen)

proc getNumber*(win: Window): int =
  int bindings.windowGetNumber(win.impl)

proc open*(win: Window; link: string; browser: Browser = BrowserAny) =
  ## Open window `win` using URL `link`.

  bindings.windowOpen(win.impl, cstring link, cuint ord(browser))

proc runBrowser*(win: Window; cmd: string): int =
  discard bindings.runBrowser(win.impl, cstring cmd)

proc browserExist*(win: Window; browser: Browser): bool =
  bindings.browserExist(win.impl, cuint ord(browser))

proc browserCreateProfileFolder*(win: Window; browser: Browser) =
  discard bindings.browserCreateProfileFolder(win.impl, cuint ord(browser))

proc browserStartEdge*(win: Window; address: string) =
  discard bindings.browserStartEdge(win.impl, cstring address)

proc browserStartFirefox*(win: Window; address: string) =
  discard bindings.browserStartFirefox(win.impl, cstring address)

proc browserStartCustom*(win: Window; address: string) =
  discard bindings.browserStartCustom(win.impl, cstring address)

proc browserStartChrome*(win: Window; address: string) =
  discard bindings.browserStartChrome(win.impl, cstring address)

proc `rootFolder=`*(win: Window; path: string) =
  discard bindings.setRootFolder(win.impl, cstring path)

proc waitProcess*(win: Window; status: bool) =
  bindings.waitProcess(win.impl, status)

proc generateJsBridge*(win: Window): string =
  $ bindings.generateJsBridge(win.impl)

# Maybe wrap script interface? 

export bindings.webui, bindings.WEBUI_VERSION

when isMainModule:
  let w = newWindow()
  w.show("<html>hello!</html>")
  wait()