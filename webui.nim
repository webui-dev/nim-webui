##[ 
  Nim wrapper for [WebUI](https://github.com/alifcommunity/webui)

  :Author: Jasmine
  :WebUI Version: 2.0.6

  # Get Started

  To begin you need to install the webui library for Nim. This installs
  WebUI's C sources for you.

  ```
  nimble install webui
  ```

  To see the wrapper's source code, please visit the GitHub repository here: 
  https://github.com/neroist/webui

  WebUI's source code is [here](https://github.com/alifcommunity/webui).

  # Example

  A very *minimal* Nim example:
]##

runnableExamples:

  let window = newWindow() # Create a new Window
  window.show("<html>Hello</html>") # Show the window with html content

  wait() # Wait until the window gets closed

##[
  To view more complex examples please visit the 
  [examples](https://github.com/neroist/webui/tree/main/examples) 
  directory in my GitHub repository.

  # Windows

  ## New Window
  
  To create a new window object, you can use `newWindow()`, which returns a 
  new window object.

  ```nim
  let window = newWindow()
  ```

  ## Show Window
  
  To show a window, you can use the `show()` function. If the window is already 
  shown, the UI will get refreshed in the same window.

  ```nim
  const html = "<html>Hello!</html>"

  window.show(html) # Shows html in any installed web browser
  ```

  To show a window in a specific web browser:
  
  ```nim
  const html = "<html>Hello!</html>"
  
  # Chrome
  window.show(html, BrowserChrome)

  # Firefox
  window.show(html, BrowserFirefox)

  # Microsoft Edge
  window.show(html, BrowserEdge)

  # Chromium
  window.show(html, BrowserChromium)

  # Safari
  window.show(html, BrowserSafari)

  # Any available web browser
  window.show(html, BrowserAny)
  ```

  If you need to update the whole UI content, you can use `refresh()`, which 
  allows you to refresh the window UI with any new HTML content.

  ```nim
  import std/os

  let html = "<html>Hello</html>"
  let newHtml = "<html>New World!</html>"

  # Open a window in Chrome
  window.show(html, BrowserChrome)

  # Later...
  sleep(5000)

  # Refresh the same window with the new content
  window.refresh(newHtml)
  ```

  ## Window Status
  
  In some exceptional cases, you want to know if any opened window exists, 
  for that, please use `isAnyWindowRunning()`, which returns `true` or `false`.

  ```nim
  if isAnyWindowRunning():
    echo "A window is running..."
  else:
    echo "No window is running."
  ```

  To know if a specific window is running, you can use `shown()`.

  ```nim
  if window.shown():
    echo "A window is running..."
  else:
    echo "No window is running."
  ```

  # Binding

  ## Bind
  
  Use `bind()` to receive click events when the user clicks on any HTML 
  element with a specific ID, for example `<button id="MyID">Hello</button>`.

  ```nim
  window.bind("MyID") do (e: Event):
    ...
  ```

  You can also have a return value on your function, it must be either of
  `string`, `int`, or `bool`. The return value will be automatically passed
  back to the Javascript code for you.

  ```nim
  window.bind("MyID") do (e: Event) -> bool:
    return 1 + 2 == 3  # true
  ```

  This also applies to `bindAll()`.

  ## Bind All
  
  You can also automatically bind all HTML elements with one function call.

  ```nim
  window.bindAll() do (e: Event):
    ...
  ```

  # Application

  ## Wait
  
  It is essential to call `wait()` at the end of your main function, after 
  you create/show all your windows. This will make your application run 
  until the user closes all visible windows or when calling `exit()`.

  ```nim
  # Create windows...
  # Bind HTML elements...
  # Show the windows...

  # Wait until all windows get closed
  # or when calling exit()

  wait()
  ```

  ## Exit
  
  At any moment, you can call `exit()`, which tries to close all related
  opened windows and make `wait()` break.

  ```nim
  exit()
  ```

  ## Close
  
  You can call `close()` to close a specific window, if there is no running 
  window left `wait()` will break.

  ```nim
  window.close()
  ```

  ## App Status
  
  In some exceptional cases, like in the WebUI-TypeScript wrapper, you 
  want to know if the whole application still running or not, for that,
  please use `isAppRunning()`, which returns `true` or `false`.

  ```nim
  if isAppRunning():
    echo "The application is still running"
  else:
    echo "The application is closed."
  ```

  ## Startup Timeout
  
  WebUI waits a couple of seconds to let the web browser start and connect, 
  you can control this behavior by using `setTimeout()`.

  ```nim
  # Wait 10 seconds for the web browser to start
  setTimeout(10)
  wait()    # After 10 seconds, if the web browser
            # did not start yet, this function will return
  ```

  ```nim
  # Wait forever.
  setTimeout(0)
  wait() # this function will never end
  ```

  ## Multi Access
  
  [](For some reason using markdown doesn't work for images...)

  .. image:: https://webui.me/docs/data/webui_access_denied.png
    :alt: WebUI access denied image

  After the window is loaded, for safety, the used URL is not valid anymore, 
  if someone else tries to access the URL WebUI will show an error. To allow 
  multi-user access to the same URL, you can use `multiAccess=`.

  ```nim
  window.multiAccess = true
  ```

  # Event

  ## Event
  
  When you use `window.bind()`, your application will receive an event every 
  time the user clicks on the specified HTML element. The event comes with 
  the `elementName`, which is The HTML ID of the clicked element, for example, 
  `MyButton`, `MyInput`, etc., The event also comes with the WebUI unique 
  element ID & the unique window ID. Those two IDs are not generally needed.

  ```nim
  proc myProc(e: Event) =
    echo "Hi!, You clicked on ", e.elementName, " element"
  ```

  The `e` corresponds to `Event`, and it has these attributes:
  
  ```nim
  e.windowId     # WebUI unique window ID
  e.elementId    # WebUI unique element ID
  e.elementName  # The HTML ID of the clicked element
  e.window       # The current window object
  ```

  You can access other attributes like `data` and `response`, but those are
  used by WebUI, and are only meant for internal use by the library.

  # Run JavaScript

  ## Script
  
  You can run JavaScript on any window to read values, update the view, or 
  anything else. In addition, you can check for execution errors, as well as 
  receive data.

  ```nim
  proc myProc(e: Event) = 
    # window.script requires a `var` type
    var js = newScript("alert('Hello');")

    e.window.script(js)
  ```

  An example of how to run a JavaScript and get back the output as string, 
  and check for errors, if any.

  ```nim
  proc myProc(e: Event) =
    var js = newScript("var foo = 4; var bar = 2; return foo*bar;") # Return '8'

    let res = e.window.script(js)

    # Check for any error
    if res.error == true:
        echo "JavaScript Error: ", res.data
    else:
        echo "Output: ", res.data # '8'
  ```

  # Server

  ## Server

  You can use WebUI to serve a folder, which makes WebUI act like a web 
  server. To do that, please use `newServer()`, which returns the complete 
  URL of the server.

  ```nim
  # Serve a folder
  let url = window.newServer("/path/to/folder")
  ```

  ```nim
  # Automatically serve the current directory
  let url = window.newServer("")
  ```

  When you serve a folder, you probably want to run JavaScript & TypeScript 
  files and show the output in the UI. To do that, you can use 
  `scriptRuntime=`, which makes WebUI act like Nodejs.

  ```nim
  # Choose your preferable runtime for .js & .ts files
  # Deno: RuntimeDeno
  # Node.js: RuntimeNodeJs

  # Deno
  window.scriptRuntime = RuntimeDeno

  # Nodejs
  window.scriptRuntime = RuntimeNodeJs

  # Disable
  window.scriptRuntime = RuntimeNone
  ```

  If you already have a URL, you can use WebUI to open a window using this 
  URL. For that, please use `open()`.

  ```nim
  setTimeout(0) # (Optional) Let the server run forever
  window.open(url, BrowserChrome) # `url` can also be a Uri from std/uri
  ```

  In addition, it can make WebUI track clicks and send you events by 
  embedding the WebUI JavaScript bridge file `webui.js`. Of course, this 
  will work only if the server is WebUI.

  [](Yes, I know, "its HTML code not Nim!!!". Nimdoc doesn't support html)
  [](code highlighting so we use Nim to to get around that.)

  ```nim
  <script src="/webui.js"></script>
  ```
]##


import std/uri

from webui/bindings import nil

type
  WindowCore* = ref object
    internalImpl*: bindings.WindowCore

  Window* = ref object
    internalImpl*: pointer

  Event* = ref object
    ## When you use `bind()`, your application will receive an event every time 
    ## the user clicks on the specified HTML element. The event comes with the 
    ## `element_name`, which is The HTML ID of the clicked element, for example,
    ## `MyButton`, `MyInput`, etc. The event also comes with the WebUI unique element 
    ## ID & the unique window ID.
  
    internalImpl*: pointer

  JavascriptResult* = ref object
    error*: bool
    length*: int
    data*: string

  Script* = ref object
    internalImpl*: bindings.Script

  CustomBrowser* = ref object
    internalImpl*: bindings.CustomBrowser

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

# forward declarations, needed for `bind` and `bindAll`
proc getNumber*(win: Window): int

# vars
var cbs: array[bindings.WEBUI_MAX_ARRAY, array[bindings.WEBUI_MAX_ARRAY, proc (e: Event)]] ## \
  ## array of binded callbacks.
  ## Needed for `bind` and `bindAll`

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

proc cmdSync*(cmd: string; show: bool): int =
  int bindings.cmdSync(cstring cmd, show)

proc cmdAsync*(cmd: string; show: bool): int =
  int bindings.cmdAsync(cstring cmd, show)

proc clean*() =
  bindings.clean()

proc browserGetTempPath*(browser: Browser): string =
  $ bindings.browserGetTempPath(cuint ord(browser))

# SKIPPED: getCurrentPath() unneccessary, use std/os
# SKIPPED: folderExist() unneccessary, use std/os
# SKIPPED: printHex() unneccessary, use std/strutils
# SKIPPED: freeMem() too low-level and unneccessary with GC
# SKIPPED: strCopy() unneccessary in general + too low-level
# SKIPPED: fileExistMg() unneccessary + too low-level
# SKIPPED: fileExist() unneccessary, use std/os

# above skipped functions seem unneccessary and/or too low-level
# if you need them, import webui/bindings

# ------- Impl funcs --------

# --- Event ---

func impl*(e: Event): ptr bindings.Event = 
  ## Returns the internal implementation of `e`

  cast[ptr bindings.Event](e.internalImpl)

func `impl=`*(e: Event, be: ptr bindings.Event) = 
  ## Sets the internal implementation of `e`

  e.internalImpl = pointer(be)

# --- WindowCore ---

func impl*(winCore: WindowCore): bindings.WindowCore = 
  ## Returns the internal implementation of `winCore`

  winCore.internalImpl

func `impl=`*(winCore: WindowCore, bwinCore: bindings.WindowCore) = 
  ## Sets the internal implementation of `winCore`

  winCore.internalImpl = bwinCore

# --- Window ---

func impl*(win: Window): ptr bindings.Window = 
  ## Returns the internal implementation of `win`

  cast[ptr bindings.Window](win.internalImpl)

func `impl=`*(win: Window, bwin: ptr bindings.Window) = 
  ## Sets the internal implementation of `win`

  win.internalImpl = pointer(bwin)

# --- Script ---

func impl*(script: Script): bindings.Script = 
  ## Returns the internal implementation of `script`

  script.internalImpl

func `impl=`*(script: Script, bwin: bindings.Script) = 
  ## Sets the internal implementation of `script`

  script.internalImpl = bwin

# -------- Custom Browser --------

# construct via var

proc app*(c: CustomBrowser): string = 
  $ c.internalImpl.app

proc arg*(c: CustomBrowser): string = 
  $ c.internalImpl.arg

proc autoLink*(c: CustomBrowser): bool = 
  c.internalImpl.autoLink

proc `app=`*(c: CustomBrowser, app: string) = 
  c.internalImpl.app = cstring app

proc `arg=`*(c: CustomBrowser, arg: string) = 
  c.internalImpl.arg = cstring arg

proc `autoLink=`*(c: CustomBrowser, autoLink: bool) = 
  c.internalImpl.autoLink = autoLink

# -------- Script --------

proc newScript*(script: string; timeout: int = 0): Script =
  ## Create a new Script object

  new result
  
  result.internalImpl.script = cstring script
  result.internalImpl.timeout = cuint timeout

proc script*(s: Script): string =
  ## Get Script `s`'s internal Javascript code
  
  $ s.internalImpl.script

proc timeout*(s: Script): int =
  ## Get Script `s`'s timeoue value
  
  int s.internalImpl.timeout

proc `script=`*(s: Script, script: string) =
  ## Set Script `s`'s internal Javascript code

  s.internalImpl.script = cstring script

proc `timeout=`*(s: Script; timeout: int) =
  ## Set Script `s`'s timeoue value

  s.internalImpl.timeout = cuint timeout

proc result*(s: Script): JavascriptResult =
  ## Get result of Script `s` after running it via [script()](#script,Window,Script)

  new result

  result.error = s.internalImpl.result.error
  result.length = int s.internalImpl.result.length
  result.data = $ s.internalImpl.result.data

proc cleanup*(s: var Script) = 
  ## Free Script `s`.
  ## 
  ## .. note:: You may not need to call this if
  ##        you're using a GC
  
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
  # doesnt work?
  # bindings.getBool(e.impl)

  e.getString() == "true"

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

proc uri*(winCore: WindowCore): Uri =
  parseUri winCore.url

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

proc runtime*(winCore: WindowCore): Runtime =
  Runtime(winCore.impl.runtime)

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

{.push discardable.}

proc show*(win: Window; html: string | Uri; browser: Browser = BrowserAny): bool = 
  ## Show Window `win`. If the window is already shown, the UI will get 
  ## refreshed in the same window.

  bindings.show(win.impl, cstring $html, cuint ord(browser))

proc showCopy*(win: Window; html: string | Uri; browser: Browser = BrowserAny): bool = 
  bindings.showCpy(win.impl, cstring $html, cuint ord(browser))

proc refresh*(win: Window; html: string): bool = 
  ## Refresh the window UI with any new HTML content.

  bindings.refresh(win.impl, cstring html)

proc refreshCopy*(win: Window; html: string): bool = 
  bindings.refreshCpy(win.impl, cstring html)

{.pop.}

proc `icon=`*(win: Window; iconS, typeS: string) = 
  bindings.setIcon(win.impl, cstring iconS, cstring typeS)

proc multiAccess*(win: Window; status: bool) {.deprecated: "Use `multiAccess=` instead".} = 
  bindings.multiAccess(win.impl, status)

proc `multiAccess=`*(win: Window; status: bool) = 
  ## After the window is loaded, for safety, the used URL is not valid anymore, 
  ## if someone else tries to access the URL WebUI will show an error.
  ## 
  ## multiAccess allows multi-user access to the same URL.
  ## 
  ## If `status` is `true`, then multiAccess will be enabled, otherwise, 
  ## multiAccess will be disabled

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
  ## Run Script `script`

  bindings.script(win.impl, addr script.internalImpl)

# * for use With `bindInterface`. We use `bind` instead, so no need for it now.
#proc interfaceHandler(elementId, windowId: cuint; elementName: cstring; window: ptr bindings.Window; data: cstring; response: cstringArray) {.cdecl.} =
#  var event: bindings.Event
#
#  event.elementId = elementId
#  event.windowId = windowId
#  event.elementName = elementName
#  event.window = window
#  event.data = data
#
#  cbs[windowId][elementId](Event(internalImpl: addr(event)))

proc bindHandler(e: ptr bindings.Event) {.cdecl.} = 
  var event = Event()
  event.impl = e

  cbs[e.windowId][e.elementId](event)

proc `bind`*(win: Window; element: string; `func`: proc (e: Event)): int {.discardable.} =
  ## Receive click events when the user clicks on any HTML element with a specific ID

  let idx = bindings.bind(win.impl, cstring element, bindHandler)
  let wid = win.getNumber()

  cbs[wid][idx] = `func`

proc `bind`*(win: Window; element: string; `func`: proc (e: Event): string): int {.discardable.} =
  win.bind(
    element, 
    proc (e: Event) =
      let res = `func`(e)
      e.returnString(res)
  )  

proc `bind`*(win: Window; element: string; `func`: proc (e: Event): int): int {.discardable.} =
  win.bind(
    element, 
    proc (e: Event) =
      let res = `func`(e)
      e.returnInt(res)
  )  

proc `bind`*(win: Window; element: string; `func`: proc (e: Event): bool): int {.discardable.} =  ## Bind `func` to element `element` and automatically pass return value of `func` to Javascript
  ## Bind `func` to element `element` and automatically pass return value of `func` to Javascript

  win.bind(
    element, 
    proc (e: Event) =
      let res = `func`(e)
      e.returnBool(res)
  )  

proc bindAll*(win: Window; `func`: proc (e: Event)) =
  ## Bind all elements
  
  bindings.bindAll(win.impl, bindHandler)
  let wid = win.getNumber()

  # bindInterface was going to return zero anyway
  #
  # C source of `webui_bind_interface`:
  #   ...
  #   if(_webui_is_empty(element)) {
  #     webui_bind_all(win, webui_bind_interface_all_handler);
  #     webui.cb_interface_all[0] = func;
  #     return 0;
  #   }
  #   ...

  cbs[wid][0] = `func`

proc bindAll*(win: Window; `func`: proc (e: Event): string) =
  win.bindAll( 
    proc (e: Event) =
      let res = `func`(e)
      e.returnString(res)
  )  

proc bindAll*(win: Window; `func`: proc (e: Event): int) =
  win.bindAll( 
    proc (e: Event) =
      let res = `func`(e)
      e.returnInt(res)
  )  

proc bindAll*(win: Window; `func`: proc (e: Event): bool) =
  ## Bind all elements to `func` automatically pass return value of `func` to Javascript

  win.bindAll( 
    proc (e: Event) =
      let res = `func`(e)
      e.returnBool(res)
  )  

proc open*(win: Window; url: string | Uri; browser: Browser = BrowserAny) =
  bindings.open(win.impl, cstring $url, cuint ord(browser))

proc scriptRuntime*(win: Window; runtime: Runtime) {.deprecated: "Use `scriptRuntime=` instead".} = 
  bindings.scriptRuntime(win.impl, cuint ord(runtime))

proc `scriptRuntime=`*(win: Window; runtime: Runtime) = 
  ## Make WebUI act like  runtime `runtime` (either NodeJS or Deno).
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

proc openLink*(win: Window; link: string | Uri; browser: Browser = BrowserAny) =
  ## Open window `win` using URL `link`.

  bindings.windowOpen(win.impl, cstring $link, cuint ord(browser))

proc runBrowser*(win: Window; cmd: string): int =
  int bindings.runBrowser(win.impl, cstring cmd)

proc browserExist*(win: Window; browser: Browser): bool =
  bindings.browserExist(win.impl, cuint ord(browser))

proc browserCreateProfileFolder*(win: Window; browser: Browser): bool {.discardable.} =
  bindings.browserCreateProfileFolder(win.impl, cuint ord(browser))

{.push discardable.}

proc browserStartEdge*(win: Window; address: string | Uri): bool =
  bindings.browserStartEdge(win.impl, cstring $address)

proc browserStartFirefox*(win: Window; address: string | Uri): bool =
  bindings.browserStartFirefox(win.impl, cstring $address)

proc browserStartCustom*(win: Window; address: string | Uri): bool =
  bindings.browserStartCustom(win.impl, cstring $address)

proc browserStartChrome*(win: Window; address: string | Uri): bool =
  bindings.browserStartChrome(win.impl, cstring $address)

{.pop.}

proc `rootFolder=`*(win: Window; path: string): bool {.discardable.} =
  bindings.setRootFolder(win.impl, cstring path)

proc waitProcess*(win: Window; status: bool) =
  bindings.waitProcess(win.impl, status)

proc generateJsBridge*(win: Window): string =
  $ bindings.generateJsBridge(win.impl)

export 
  bindings.webui, 
  bindings.WEBUI_VERSION
