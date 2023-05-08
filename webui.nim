##[ 
  Nim wrapper for [WebUI](https://github.com/alifcommunity/webui)

  :Author: Jasmine
  :WebUI Version: 2.1.1

  See: https://neroist.github.io/webui-docs/
]##

import std/strutils

from webui/bindings import nil

type
  Window* = distinct int

  Event* = ref object
    ## When you use `bind()`, your application will receive an event every time 
    ## the user clicks on the specified HTML element. The event comes with the 
    ## `element_name`, which is The HTML ID of the clicked element, for example,
    ## `MyButton`, `MyInput`, etc. The event also comes with the WebUI unique element 
    ## ID & the unique window ID.
  
    internalImpl*: ptr bindings.Event

# vars

var 
  cbs: array[bindings.WEBUI_MAX_IDS, array[bindings.WEBUI_MAX_IDS, proc (e: Event)]]
    ## array of binded callbacks.
    ## Needed for `bind`

proc wait*() =
  ## Run application run until the user closes all 
  ## visible windows or when calling `exit() <#exit>`_

  bindings.wait()

proc exit*() = 
  ## Try and close all related opened windows and make `wait() <#wait>`_ break.

  bindings.exit()

proc setTimeout*(timeout: int) = 
  ## Waits `timeout` seconds to let the web browser start and connect.
  ## 
  ## Set `timeout` to `0` to wait forever.
  
  bindings.setTimeout(csize_t timeout)

# ------- Impl funcs --------

# --- Event ---

func impl*(e: Event): ptr bindings.Event = 
  ## Returns the internal implementation of `e`

  e.internalImpl

func `impl=`*(e: Event, be: ptr bindings.Event) = 
  ## Sets the internal implementation of `e`

  e.internalImpl = be

# -------- Event --------

proc element*(e: Event): string =
  $ e.impl.element

proc window*(e: Event): Window =
  result = Window(int e.impl.window)

proc data*(e: Event): string =
  $ e.impl.data

proc eventNumber*(e: Event): int =
  int e.impl.eventNumber

proc eventType*(e: Event): bindings.Events =
  bindings.Events(int e.impl.eventType)

proc getInt*(e: Event): int =
  int bindings.getInt(e.internalImpl)

proc getString*(e: Event): string =
  $ bindings.getString(e.internalImpl)

proc getBool*(e: Event): bool =
  bindings.getBool(e.internalImpl)

proc returnInt*(e: Event; n: int) = 
  bindings.returnInt(e.internalImpl, clonglong n)

proc returnString*(e: Event; s: string) =
  bindings.returnString(e.internalImpl, cstring s)

proc returnBool*(e: Event; b: bool) =
  bindings.returnBool(e.internalImpl, b)

# -------- Window --------

proc newWindow*(): Window =
  ## Create new Window object

  result = Window(bindings.newWindow())

proc newWindow*(windowNumber: int): Window = 
  ## Create a new Window object
  
  bindings.newWindowId(csize_t windowNumber)
  result = Window(windowNumber)

{.push discardable.}

proc show*(win: Window; content: string): bool = 
  ## Show Window `win`. If the window is already shown, the UI will get 
  ## refreshed in the same window.
  ## `content` can be a file name, or a static HTML script

  bindings.show(csize_t win, cstring content)

proc show*(win: Window; content: string; browser: bindings.Browsers): bool =
  bindings.showBrowser(csize_t win, cstring content, csize_t ord(browser))

{.pop.}

proc `icon=`*(win: Window; icon, `type`: string) = 
  bindings.setIcon(csize_t win, cstring icon, cstring type)

proc `multiAccess=`*(win: Window; status: bool) = 
  ## Allow the window URL to be re-used in normal web browsers

  bindings.setMultiAccess(csize_t win, status)

proc `kiosk=`*(win: Window; status: bool) = 
  ## Set the window in Kiosk mode (Full screen)
  
  bindings.setKiosk(csize_t win, status)

proc close*(win: Window) = 
  ##  Close a specific window only. The window object will still exist.
  
  bindings.close(csize_t win)

proc destroy*(win: Window) =
  ## Close a specific window and free all memory resources.
  
  bindings.destroy(csize_t win)

proc shown*(win: Window): bool = 
  ## Return if window is still running

  bindings.isShown(csize_t win)

proc script*(win: Window; script: string; timeout: int = 0, bufferLen: static[int] = 1024 + 8): tuple[data: string; error: bool] =
  ## Run script `script`
  
  var buffer: array[bufferLen, char]

  let error = bindings.script(csize_t win, cstring script, csize_t timeout, cast[cstring](addr buffer), csize_t bufferLen)

  result.data = buffer.join()
  result.error = error

proc run*(win: Window; script: string): bool {.discardable.} =
  ## Evaluate Javascript code `script` and return the result

  bindings.run(csize_t win, cstring script)
  
#proc interfaceHandler(window: csize_t; eventType: csize_t; element: cstring; data: cstring; eventNumber: csize_t) {.cdecl.} =
#  var event = bindings.Event()
#
#  event.element = element
#  event.window = window
#  event.data = data
#  event.eventType = eventType
#  event.eventNumber = eventNumber
#
#  var e = Event(
#    internalImpl: addr event
#  )
#
#  new e
#
#  cbs[bindings.interfaceGetWindowId(window)][bindings.interfaceGetBindId(window, element)](e)

proc bindHandler(e: ptr bindings.Event) {.cdecl.} = 
  var event = Event(internalImpl: e)

  cbs[bindings.interfaceGetWindowId(e.window)][bindings.interfaceGetBindId(e.window, e.element)](event)

proc `bind`*(win: Window; element: string; `func`: proc (e: Event)) =
  ## Receive click events when the user clicks on any HTML element with a specific ID

  let bid = int bindings.bind(csize_t win, cstring element, bindHandler)
  let wid = int bindings.interfaceGetWindowId(csize_t win)
  
  cbs[wid][bid] = `func`

proc `bind`*(win: Window; element: string; `func`: proc (e: Event): string) =
  win.bind(
    element, 
    proc (e: Event) =
      let res = `func`(e)
      e.returnString(res)
  )  

proc `bind`*(win: Window; element: string; `func`: proc (e: Event): int) =
  win.bind(
    element, 
    proc (e: Event) =
      let res = `func`(e)
      e.returnInt(res)
  )  

proc `bind`*(win: Window; element: string; `func`: proc (e: Event): bool) =  
  ## Bind `func` to element `element` and automatically pass return value of `func` to Javascript

  win.bind(
    element, 
    proc (e: Event) =
      let res = `func`(e)
      e.returnBool(res)
  )  

proc `runtime=`*(win: Window; runtime: bindings.Runtime) = 
  bindings.setRuntime(csize_t win, csize_t ord(runtime))

export 
  bindings.Events, 
  bindings.Browsers, 
  bindings.Runtime, 
  bindings.WEBUI_VERSION,
  bindings.WEBUI_MAX_IDS
