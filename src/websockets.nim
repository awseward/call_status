import asyncdispatch
import ws

var websockets: seq[WebSocket] = @[]

proc wsAdd*(ws: WebSocket) =
  websockets.add ws

proc wsRefreshAll*() =
  # TODO: Also clean up Closed ones
  for ws in websockets:
    if ws.readyState == Open:
      ws.close()
