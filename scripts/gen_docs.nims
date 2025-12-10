# nim ./scripts/gen_docs.nims

import os, strformat, strutils

let cmd = "nim doc ./webui.nim"
exec cmd

let copy_index_cmd = "cp -vf ./docs/theindex.html ./docs/index.html"
exec copy_index_cmd

