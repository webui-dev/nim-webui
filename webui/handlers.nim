import std/pathnorm
import std/macros
import std/os

macro dynamicHandler*(dir: string = ".", isStatic: bool): untyped =
  ## Dynamic file handler, serving files from `dir`.

  var branches: seq[tuple[cond, body: NimNode]]

  for file in walkDirRec($dir, relative=true):
    
    var currBranch: tuple[cond, body: NimNode]

    currBranch.cond = infix(ident"filename", "==", newStrLitNode("/" & file.normalizePath('/')))
    currBranch.body = newNimNode(nnkReturnStmt).add(newCall(ident"readFile", newStrLitNode($dir / file)))

    branches.add currBranch

  let body = newNimNode(nnkIfStmt)

  for branch in branches:
    body.add newTree(nnkElifBranch, branch.cond, branch.body)

  result = newProc(params=[ident"string", newIdentDefs(ident"filename", ident"string")], body=body)

# better approach?
macro staticHandler*(dir: string = "."): untyped =
  ## Static file handler, serving files from `dir`.
  ## `dir` should not be too large or have files that are too big.
  ## 
  ## `dir` is relative to the current working directory.
  ## 
  ## **ISSUE**: results in longer compilation times
  
  var branches: seq[tuple[cond, body: NimNode]]

  for file in walkDirRec($dir, relative=true):
    
    var currBranch: tuple[cond, body: NimNode]
    let cont = readFile($dir / file)

    currBranch.cond = infix(ident"filename", "==", newStrLitNode("/" & file.normalizePath('/')))
    currBranch.body = newNimNode(nnkReturnStmt).add(newStrLitNode(cont))

    branches.add currBranch

  let body = newNimNode(nnkIfStmt)

  for branch in branches:
    body.add newTree(nnkElifBranch, branch.cond, branch.body)

  result = newProc(params=[ident"string", newIdentDefs(ident"filename", ident"string")], body=body)
