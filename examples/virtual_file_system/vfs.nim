import std/strformat
import std/httpcore
import std/tables
import std/os

import webui

type
  HttpResponse = ref object
    code: HttpCode
    headers: Table[string, string] # TODO use TableRef
    body: string

const
  fileRoot = currentSourcePath /../ "ui"
  virtualFiles = toTable({
    "/index.html": slurp(fileRoot / "index.html"),
    "/sub/index.html": slurp(fileRoot / "sub/index.html"),
    "/svg/webui.svg": slurp(fileRoot / "svg/webui.svg")
  })
  indexFiles = toTable({
    "//": "/index.html",
    "/sub/": "/sub/index.html"
  })

  HttpNewLine = "\r\n"

proc `$`*(resp: HttpResponse): string =
  # build status line
  result.add(fmt"HTTP/1.1 {resp.code}" & HttpNewLine)

  # add headers
  for key, val in resp.headers:
    result.add(fmt"{key}: {val}" & HttpNewLine)
  
  # add seperator between headers and message body
  result.add HttpNewLine

  # finally, add response body
  result.add resp.body

proc fileHandler*(path: string): string =
  let redirectPath =
    if path[^1] != '/': path & '/'
    else: path

  var resp = new HttpResponse
  defer: result = $resp

  if virtualFiles.hasKey(path):
    resp.code = Http200
    resp.headers["Content-Type"] = path.getMimeType()
    resp.headers["Content-Length"] = $virtualFiles[path].len
    resp.headers["Cache-Control"] = "no-cache"

    resp.body = virtualFiles[path]
  elif indexFiles.hasKey(redirectPath):
    resp.code = Http302
    resp.headers["Location"] = indexFiles[redirectPath]
    resp.headers["Cache-Control"] = "no-cache"
  # webui will handle the 404
