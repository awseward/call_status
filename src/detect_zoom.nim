import osproc
import strutils
import system

import ./misc

const MacosCommand = "ps aux | grep -c --regexp='zoom.*[C]ptHost'"

proc isZoomCallActive*(): bool =
  when hostOS == "macosx":
    let (output, errorCode) = execCmdEx MacosCommand
    let exitZero = (errorCode == 0)
    let parsedOutput = parseint(output.strip())

    if exitZero and parsedOutput > 0:
      result = true
    elif (not exitZero) and parsedOutput == 0:
      result = false
    else:
      stderr.writeLine misc.dedent("""
          ERROR: Nonzero exit code
          Message: $1
        """ % [output]
      )
      result = false
  else:
    raise Exception.newException "Unsupported host OS: " & hostOS
