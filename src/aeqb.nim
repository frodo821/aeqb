# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import core/aeqb_impl
import os, strutils

when isMainModule:
  let argv = commandLineParams()

  if argv.len == 0:
    let an = paramStr(0)
    echo "Usage: " & an & " <script file>"
    echo "read input from stdin"
    quit(0)

  let src = block:
    let file = open(argv[0], FileMode.fmRead)

    defer:
      file.close()

    file.readAll()

  let cs = src.compile()
  var input = stdin.readAll()
  input.stripLineEnd()
  let (output, _) = cs.execute(input)

  echo output
