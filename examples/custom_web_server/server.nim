import std/asynchttpserver
import std/asyncdispatch

proc main {.async.} =
  var server = newAsyncHttpServer()

  proc cb(req: Request) {.async.} =
    # echo (req.reqMethod, req.url, req.headers)
    
    let headers = {"Content-type": "text/plain; charset=utf-8"}
    await req.respond(Http200, "Hello World", headers.newHttpHeaders())

  server.listen(Port(8080))
  
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(cb)
    else:
      await sleepAsync(500)

waitFor main()