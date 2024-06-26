##[ 
  Nim wrapper for [WebUI](https://github.com/webui-dev/webui)

  :author: neroist
  :WebUI Version: 2.5.0-Beta

  See: https://neroist.github.io/webui-docs/
]##

from webui/bindings import nil

type
  Window* = distinct int

  Event* = ref object
    ## When you use `bind()`, your application will receive an event every time 
    ## the user clicks on the specified HTML element. The event comes with the 
    ## `element`, which is The HTML ID of the clicked element, for example,
    ## `"MyButton"`, `"MyInput"`, etc. The event also comes with the element ID
    ## & the unique window ID.
  
    internalImpl*: ptr bindings.Event

# vars

var 
  cbs: array[bindings.WEBUI_MAX_IDS, array[bindings.WEBUI_MAX_IDS, proc (e: Event)]]
    ## array of binded callbacks.
    ## Needed for `bind`

  currHandler: proc (filename: string): string
    ## Most recent file handler set by `fileHandler=`.
    ## Needed for `fileHandler=`.

proc wait*() =
  ## Wait until all opened windows get closed.

  bindings.wait()

proc exit*() =
  ## Close all opened windows. `wait()` will break.

  bindings.exit()

proc setTimeout*(timeout: int) =
  ## Set the maximum time in seconds to wait for browser to start.
  ## 
  ## Set `timeout` to `0` to wait forever. 
  ## 
  ## :timeout: The maximum time in seconds to wait for browser to start.
  ##           Set to `0` to wait forever.
  
  bindings.setTimeout(csize_t timeout)

proc encode*(str: string): string = 
  ## Base64 encoding. Use this to safely send text based data to the UI.
  ## If it fails it will return an empty string.
  ## 
  ## :str: The string to encode.

  var cstr = bindings.encode(cstring str)
  result = $cstr

  bindings.free(addr cstr)

proc decode*(str: string): string = 
  ## Base64 decoding. Use this to safely decode received Base64 text from the UI.
  ## If it fails it will return an empty string.
  ## 
  ## :str: The string to decode.

  var cstr = bindings.decode(cstring str)
  result = $cstr
  
  bindings.free(addr cstr)

proc setDefaultRootFolder*(path: string): bool {.discardable.} = 
  ## Set the web-server root folder path for all windows. 
  ## 
  ## .. note:: Should be used before `webui_show()`.
  ## 
  ## :path: The path to the root folder.

  bindings.setDefaultRootFolder(cstring path)

proc clean*() =
  ## Free all memory resources. Should be called only at the end.
  
  bindings.clean()

proc deleteAllProfiles*() =
  ## Delete all local web-browser profiles folder. It should be called at the end.
  
  bindings.deleteAllProfiles()

proc setTlsCertificate*(certificate_pem, private_key_pem: string): bool =
  ## Set the SSL/TLS certificate and the private key content, both in PEM
  ## format. This works only with `webui-2-secure` library. If set empty, WebUI
  ## will generate a self-signed certificate.
  ## 
  ## :certificate_pem: The SSL/TLS certificate content in PEM format
  ## :private_key_pem: The private key content in PEM format
  ## 
  ## Returns `true` if the certificate and the key are valid.
  
  bindings.setTlsCertificate(cstring certificate_pem, cstring private_key_pem)

proc isHighContrast*(): bool =
  ## Get the OS's high contrast preference.
  ##
  ## Returns `true` if the OS prefers a high contrast theme.

  bindings.isHighContrast()

proc browserExist*(browser: bindings.WebuiBrowser): bool =
  ## Check if a web browser is installed.
  ##
  ## Returns `true` if the specified browser is available.

  bindings.browserExist(browser)

proc setConfig*(option: bindings.WebuiConfig; status: bool) =
  ## Control WebUI's behaviour via setting configuration option `option` to either
  ## `true` or `false`. It's better to this call at the beginning of your program.
  ## 
  ## :option: The desired option from the `WebuiConfig` enum
  ## :status: The status of the option, `true` or `false`
  
  bindings.setConfig(option, status)

# ------- Impl funcs --------

# --- Event ---

func impl*(event: Event): ptr bindings.Event = 
  ## Returns the internal implementation of `e`

  event.internalImpl

func `impl=`*(event: Event, be: ptr bindings.Event) =
  ## Sets the internal implementation of `e`

  event.internalImpl = be

# -------- Event --------

proc window*(event: Event): Window =
  result = Window(int event.impl.window)

proc eventType*(event: Event): bindings.WebuiEvent =
  bindings.WebuiEvent(int event.impl.eventType)

proc element*(event: Event): string =
  $ event.impl.element

proc eventNumber*(event: Event): int =
  int event.impl.eventNumber

proc bindId*(event: Event): int =
  int event.impl.bindId

# --- 

proc getCount*(event: Event): int =
  ## Get how many arguments there are in an event.
  ## 
  ## :event: The event 

  int bindings.getCount(event.internalImpl)

proc getInt*(event: Event, index: int): int =
  ## Get an argument as integer at a specific index
  ## 
  ## :event: The event 
  ## :index: The argument position starting from 0

  int bindings.getIntAt(event.internalImpl, csize_t index)

proc getInt*(event: Event): int =
  ## Get the first argument as integer
  ## 
  ## :event: The event 

  int bindings.getInt(event.internalImpl)

proc getFloat*(event: Event, index: int): float =
  ## Get an argument as integer at a specific index
  ## 
  ## :event: The event 
  ## :index: The argument position starting from 0

  float bindings.getFloatAt(event.internalImpl, csize_t index)

proc getFloat*(event: Event): float =
  ## Get the first argument as a float
  ## 
  ## :event: The event 

  float bindings.getFloat(event.internalImpl)

proc getString*(event: Event, index: int): string =
  ## Get an argument as string at a specific index
  ## 
  ## :event: The event 
  ## :index: The argument position starting from 0
  
  $ bindings.getStringAt(event.internalImpl, csize_t index)

proc getString*(event: Event): string =
  ## Get the first argument as string
  ## 
  ## :event: The event 
  
  $ bindings.getString(event.internalImpl)

proc getBool*(event: Event, index: int): bool =
  ## Get an argument as boolean at a specific index
  ## 
  ## :event: The event 
  ## :index: The argument position starting from 0

  bool bindings.getBoolAt(event.internalImpl, csize_t index)

proc getBool*(event: Event): bool =
  ## Get the first argument as boolean
  ## 
  ## :event: The event 

  bool bindings.getBool(event.internalImpl)

proc getSize*(event: Event, index: int): int =
  ## Get the size in bytes of an argument at a specific index
  ## 
  ## :event: The event 
  ## :index: The argument position starting from 0

  int bindings.getSizeAt(event.internalImpl, csize_t index)

proc getSize*(event: Event): int =
  ## Get size in bytes of the first argument
  ## 
  ## :event: The event 

  int bindings.getSize(event.internalImpl)

proc returnInt*(event: Event; integer: int) =
  ## Return the response to JavaScript as a integer.
  ## 
  ## :event: The event to set the response for
  ## :integer: The int to return back to Javascript.

  bindings.returnInt(event.internalImpl, clonglong integer)

proc returnFloat*(event: Event; f: float) =
  ## Return the response to JavaScript as a float.
  ## 
  ## :event: The event to set the response for
  ## :integer: The float to return back to Javascript.

  bindings.returnFloat(event.internalImpl, cdouble f)

proc returnString*(event: Event; str: string) =
  ## Return the response to JavaScript as a string.
  ## 
  ## :event: The event to set the response for
  ## :str: The string to return back to Javascript.

  bindings.returnString(event.internalImpl, cstring str)

proc returnBool*(event: Event; b: bool) =
  ## Return the response to JavaScript as a boolean.
  ## 
  ## :event: The event to set the response for
  ## :b: The bool to return back to Javascript.

  bindings.returnBool(event.internalImpl, b)

# -------- Window --------

proc newWindow*(): Window =
  ## Create a new WebUI window object.

  result = Window(bindings.newWindow())

proc newWindow*(windowNumber: int): Window = 
  ## Create a new webui window object using a specified window ID.
  ## 
  ## :windowNumber: The window ID (should be within the range of `0..<WEBUI_MAX_IDS`)
  
  result = Window(bindings.newWindowId(csize_t windowNumber))

proc getNewWindowId*(): int = 
  ## Get new window ID. To be used in conjuction with
  ## `newWindow(int)`_.
  ## 
  ## Returns the first available free window number. Starting from 1.
  
  int bindings.getNewWindowId()

proc childProcessId*(window: Window): int =
  ## Get the ID of the last child process.
  ## 
  ## :window: The window

  int bindings.getChildProcessId(csize_t window)

proc parentProcessId*(window: Window): int =
  ## Get the ID of the parent process (The web browser may re-create
  ## another new process).
  ## 
  ## :window: The window

  int bindings.getParentProcessId(csize_t window)

proc getBestBrowser*(window: Window): bindings.WebuiBrowser =
  ## Get the "best" browser to be used. If running `show()`, this function will
  ## return the same browser that will be used.
  ## 
  ## :window: The window

  bindings.WebuiBrowser(bindings.getBestBrowser(csize_t window))

{.push discardable.}

proc show*(window: Window; content: string): bool = 
  ## Show a window using embedded HTML, or a file. If the window is already
  ## open, it will be refreshed.
  ## 
  ## .. important:: Please include `<script src="webui.js"></script>` in the HTML
  ##                for proper window communication. 
  ## 
  ## :window: The window to show `content` in. If the window is already
  ##          shown, the UI will get refreshed in the same window.
  ## :content: The content to show in `window`. Can be a file name, or a
  ##           static HTML script.
  ## 
  ## Returns `true` if showing the window is a success.

  bindings.show(csize_t window, cstring content)

proc show*(window: Window; content: string; browser: bindings.WebuiBrowser): bool =
  ## Same as `show() <#show,Window,string>`_, but with a specific web browser.    
  ##
  ## .. important:: Please include `<script src="webui.js"></script>` in the HTML
  ##                for proper window communication. 
  ##
  ## :window: The window to show `content` in. If the window is already
  ##          shown, the UI will get refreshed in the same window.
  ## :content: The content to show in `window`. Can be a file name, or a
  ##           static HTML script.
  ## :browser: The browser to open the window in.
  ## 
  ## Returns `true` if showing the window is a success.

  bindings.showBrowser(csize_t window, cstring content, csize_t ord(browser))

proc show*(window: Window; content: string; browsers: openArray[bindings.WebuiBrowser] or set[bindings.WebuiBrowser]): bool =
  ## Same as `show() <#show,Window,string>`_, but with a specific set of web browsers to use.    
  ## 
  ## .. important:: Please include `<script src="webui.js"></script>` in the HTML
  ##                for proper window communication. 
  ##
  ## :window: The window to show `content` in. If the window is already
  ##          shown, the UI will get refreshed in the same window.
  ## :content: The content to show in `window`. Can be a file name, or a
  ##           static HTML script.
  ## :browser: The browsers to open the window in.
  ## 
  ## Returns `true` if showing the window is a success.

  for browser in browsers:
    if bindings.showBrowser(csize_t window, cstring content, csize_t ord(browser)):
      return true

proc showWv*(window: Window; content: string): bool =
  ## Show a WebView window using embedded HTML, or a file. If the window is already
  ## open, it will be refreshed. 
  ## 
  ## .. note:: On Windows, you will need `WebView2Loader.dll`.
  ## 
  ## :window: The window
  ## :content: The HTML, URL, or a local file
  ## 
  ## Returns `true` if showing the WebView window succeeded.

  bindings.showWv(csize_t window, cstring content)

{.pop.}

proc `port=`*(window: Window, port: int) =
  ## Set a custom web-server network port to be used by WebUI.
  ## This can be useful to determine the HTTP link of `webui.js` in case
  ## you are trying to use WebUI with an external web-server like NGNIX
  ## 
  ## :window: The window
  ## :port: The web-server network port WebUI should use
  
  bindings.setPort(csize_t window, csize_t port)

proc setIcon*(window: Window; icon, mime: string) =
  ## Set the default embedded HTML favicon.
  ## 
  ## :window: The window to set the icon for.
  ## :icon: The icon as string: `<svg>...</svg>`
  ## :mime: The MIME type of the icon

  bindings.setIcon(csize_t window, cstring icon, cstring mime)

proc `public=`*(window: Window; status: bool) =
  ## Allow a specific window address to be accessible from a public network
  ## 
  ## :window: The window
  ## :status: Whether or not to set public. `true` to enable, `false`
  ##          to disable.

  bindings.setPublic(csize_t window, status)

proc `kiosk=`*(window: Window; status: bool) =
  ## Set the window in Kiosk mode (full screen).
  ## 
  ## :window: The window to enable or disable kiosk mode in.
  ## :status: Whether or not to enable kiosk mode. `true` to enable, `false`
  ##          to disable.
  
  bindings.setKiosk(csize_t window, status)

proc `runtime=`*(window: Window; runtime: bindings.WebuiRuntime) =
  ## Chose a runtime for .js and .ts files.
  ## 
  ## :window: The window to set the runtime for.
  ## :runtime: The runtime to set.
  
  bindings.setRuntime(csize_t window, csize_t ord(runtime))

proc `rootFolder=`*(window: Window; path: string): bool {.discardable.} = 
  ## Set the web-server root folder path.
  ## 
  ## :window: The window to set the root folder for.
  ## :path: The path to the root folder.

  bindings.setRootFolder(csize_t window, cstring path)

proc `hidden=`*(window: Window; status: bool) =
  ## Run the window in hidden mode
  ## 
  ## :window: The window to hide or show.
  ## :status: Whether or not to hide the window. `true` to hide, `false`
  ##          to show.
  
  bindings.setHide(csize_t window, status)

proc `highContrast=`*(window: Window; status: bool) = 
  ## Setup the window with high-contrast support. Useful when you want to 
  ## build a better high-contrast theme with CSS.
  ## 
  ## :window: The window to set the high contrast theme support for.
  ## :status: Whether or not to support high contrast themes.
  
  bindings.setHighContrast(csize_t window, status)

proc `eventBlocking=`*(window: Window; status: bool) =
  ## Control if UI events comming from this window should be processed
  ## one a time in a single blocking thread (`true`), or process every event in
  ## a new non-blocking thread (`false`). This function only affects a single window 
  ## You may use `setConfig(wcUiEventBlocking, ...)` to update all windows.
  ## 
  ## :window: The window to configure event blocking for.
  ## :status: Whether or not to process window events blockingly *(single vs multi-threaded)*.

  bindings.setEventBlocking(csize_t window, status)

proc `proxy=`*(window: Window, proxyServer: string) =
  ## Set the web browser to use `proxyServer`. Must be called before `show()`.
  ## 
  ## :window: The window to set the proxy server for
  ## :proxyServer: The proxy server to use
  
  bindings.setProxy(csize_t window, cstring proxyServer)

proc setSize*(window: Window; width, height: int) =
  ## Set the window size.
  ## 
  ## :window: The window.
  ## :width: The window width.
  ## :height: The window height.

  bindings.setSize(csize_t window, cuint width, cuint height)

proc setPos*(window: Window; x, y: int) =
  ## Set the window position.
  ## 
  ## :window: The window.
  ## :x: The window's X coordinate.
  ## :y: The window's Y coordinate.

  bindings.setPosition(csize_t window, cuint x, cuint y)

proc `size=`*(window: Window; size: tuple[width, height: int]) {.deprecated: "Use `setSize` instead".} =
  ## Alias for `setSize`_  

  bindings.setSize(csize_t window, cuint size.width, cuint size.height)

proc `pos=`*(window: Window; pos: tuple[x, y: int]) {.deprecated: "Use `setPos` instead".} = 
  ## Alias for `setPos`_

  bindings.setPosition(csize_t window, cuint pos.x, cuint pos.y)

proc close*(window: Window) =
  ## Close a specific window only. The window object will still exist.
  ## 
  ## :window: The window to close.
  
  bindings.close(csize_t window)

proc destroy*(window: Window) =
  ## Close a specific window and free all memory resources.
  ## 
  ## :window: The window to destroy.
  
  bindings.destroy(csize_t window)

proc shown*(window: Window): bool = 
  ## Return if window `window` is still running
  ## 
  ## :window: The window to return `true` if still running.

  bindings.isShown(csize_t window)

proc script*(window: Window; script: string; timeout: int = 0, bufferLen: static[int] = 1024 * 8): tuple[data: string; error: bool] =
  ## Run Javascript code `script` and return the result
  ## 
  ## Returns a tuple containing the response (`data`) and whether or not
  ## there was an error (`error`, true if an error occured, false otherwise).
  ## If an error occured, the error message will be held in `data`.
  ## 
  ## :window: The window to run the Javascript code in.
  ## :script: The Javascript code to execute.
  ## :timeout: How long to wait, at most, for a response.
  ## :bufferLen: How large to make the buffer for the response. Default is
  ##             8 kibibytes. (For larger responses make `bufferLen` larger)
  
  var buffer: array[bufferLen, char]

  let 
    error = bindings.script(csize_t window, cstring script, csize_t timeout, cast[cstring](addr buffer[0]), csize_t bufferLen)

    data = $(cast[cstring](addr buffer[0])) # remove trailing null chars

  result.data = data
  result.error = not error

proc run*(window: Window; script: string) =
  ## Run JavaScript quickly without waiting for the response.
  ## 
  ## :window: The window to run the Javascript code in.
  ## :script: The Javascript code to execute.

  bindings.run(csize_t window, cstring script)
  
# proc interfaceHandler(window: csize_t; eventType: csize_t; element: cstring; data: cstring; eventNumber: csize_t) {.cdecl.} =
#   var event = bindings.Event()
# 
#   event.element = element
#   event.window = window
#   event.data = data
#   event.eventType = eventType
#   event.eventNumber = eventNumber
# 
#   var e = Event(
#     internalImpl: addr event
#   )
# 
#   cbs[bindings.interfaceGetWindowId(window)][bindings.interfaceGetBindId(window, element)](e)

proc bindHandler(e: ptr bindings.Event) {.cdecl.} = 
  var event = Event(internalImpl: e)

  #cbs[bindings.interfaceGetWindowId(e.window)][bindings.interfaceGetBindId(e.window, e.element)](event)
  cbs[bindings.interfaceGetWindowId(e.window)][e.bindId](event)

proc `bind`*(window: Window; element: string; `func`: proc (e: Event)) =
  ## Bind a specific html element click event with a function. Empty element means all events.
  ## 
  ## Each element can have only one function bound to it.
  ## 
  ## :window: The window to bind the function onto.
  ## :element: The element to bind the function `func` to. `func` will be
  ##           called on click events. An empty element means `func` will
  ##           be bound to all events.
  ## :func: The function to bind to `element`. 

  let bid = int bindings.bind(csize_t window, cstring element, bindHandler)
  let wid = int bindings.interfaceGetWindowId(csize_t window)
  
  cbs[wid][bid] = `func`

proc `bind`*(window: Window; element: string; `func`: proc (e: Event): string) =
  window.bind(
    element, 
    proc (e: Event) =
      let res = `func`(e)
      e.returnString(res)
  )

proc `bind`*(window: Window; element: string; `func`: proc (e: Event): int) =
  window.bind(
    element, 
    proc (e: Event) =
      let res = `func`(e)
      e.returnInt(res)
  )

proc `bind`*(window: Window; element: string; `func`: proc (e: Event): float) =
  window.bind(
    element, 
    proc (e: Event) =
      let res = `func`(e)
      e.returnFloat(res)
  )

proc `bind`*(window: Window; element: string; `func`: proc (e: Event): bool) =
  ## Bind `func` to element `element` and automatically pass return value of `func` to Javascript.
  ## 
  ## :window: The window to bind the function onto.
  ## :element: The element to bind the function `func` to. `func` will be
  ##           called on click events. An empty element means `func` will
  ##           be called on all events.
  ## :func: The function to bind to `element`.

  window.bind(
    element, 
    proc (e: Event) =
      let res = `func`(e)
      e.returnBool(res)
  )

proc fileHandlerImpl(filename: cstring, length: ptr cint): pointer {.cdecl.} =
  let content = currHandler($filename)

  if content.len == 0:
    return nil

  # Always set length for memory safety, especially with binaries with '\0' inside
  length[] = cint content.len

  # Use webui_malloc to ensure memory safety
  let mem = bindings.malloc(csize_t content.len)
  copyMem(mem, cstring content, content.len)

  return mem

proc `fileHandler=`*(window: Window; handler: proc (filename: string): string) =
  ## Set a custom handler to serve files.
  ## 
  ## :window: The window to set the file handler.
  ## :runtime: The file handler callback/proc.

  currHandler = handler

  bindings.setFileHandler(csize_t window, fileHandlerImpl)

proc setFileHandler*(window: Window; handler: proc (filename: string): string) =
  ## Same as `fileHandler=`, but targeted towards use with `do` notation

  window.fileHandler = handler

proc sendRaw*(window: Window; function: string; raw: pointer; size: uint) =
  ## Safely send raw data to the UI.
  ## 
  ## :window: The window to send the raw data to.
  ## :function: The JavaScript function to receive raw data: `function myFunc(myData){}`
  ## :raw: The raw data buffer.
  ## :size: The size of the raw data in bytes.
  
  bindings.sendRaw(csize_t window, cstring function, raw, csize_t size)

proc setPosition*(window: Window; x, y: int) =
  ## Set window position
  ## 
  ## :window: The window to set the size for.
  ## :x: What to set the window's X to.
  ## :y: What to set the window's Y to.

  bindings.setPosition(csize_t window, cuint x, cuint y)

proc setProfile*(window: Window; name, path: string) =
  ## Set the web browser profile to use. An empty `name` and `path` means
  ## the default user profile. 
  ## 
  ## .. note:: Needs to be called before `webui_show()`.
  ## 
  ## :window: The window to set the browser profile for.
  ## :name: The web browser profile name.
  ## :path: The web browser profile full path.
  
  runnableExamples:
    window.setProfile("Bar", "/Home/Foo/Bar")
    window.setProfile("", "")

  bindings.setProfile(csize_t window, cstring name, cstring path)
  
proc url*(window: Window): string =
  ## Get the full current URL
  ## 
  ## :window: The window to get the URL from
  
  $ bindings.getUrl(csize_t window)
  
proc navigate*(window: Window, url: string) =
  ## Navigate to a specific URL
  ## 
  ## :window: The window to navigate on
  ## :url: The URL to navigate to
  
  bindings.navigate(csize_t window, cstring url)

proc deleteProfile*(window: Window) =
  ## Delete a specific window web-browser local folder profile.
  ## 
  ## :window: The window whose profile will be deleted

  bindings.deleteProfile(csize_t window)

export 
  bindings.WebuiEvent, 
  bindings.WebuiBrowser, 
  bindings.WebuiRuntime, 
  bindings.WebuiConfig, 
  bindings.WEBUI_VERSION,
  bindings.WEBUI_MAX_IDS
