import osproc
import strutils
import system

const MACOS_COMMAND = "ps aux | grep -c --regexp='zoom.*[C]ptHost'"

proc isZoomCallActive*(): bool =
  when hostOS == "macosx":
    let (output, errorCode) = execCmdEx MACOS_COMMAND
    let exitZero = (errorCode == 0)
    let parsedOutput = parseint(output.strip())

    if exitZero and parsedOutput > 0:
      result = true
    elif (not exitZero) and parsedOutput == 0:
      result = false
    else:
      stderr.writeLine """
        ERROR: Nonzero exit code
        Message: $1
      """
      result = false
  else:
    raise Exception.newException "Unsupported host OS: " & hostOS
