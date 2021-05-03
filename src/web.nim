import asyncdispatch
import base64
import jester
import json
import os
import sequtils
import strtabs
import strutils
import sugar
import times
import uri

import ws

import ./db_web
import ./logs
import ./models/person
import ./models/status
import ./mqtt
import ./views/index
import ./statics
import ./websockets

let settings = newSettings()
if existsEnv("PORT"):
  settings.port = Port(parseInt(getEnv("PORT")))

logs.setupWeb()

info "version:  ", pkgVersion
info "revision: ", pkgRevision

proc publishUpdates() =
  wsRefreshAll()

if defined(release):
  publishUpdates()

proc mkWebSocket(request: Request, protocol: string = "") : Future[ws.WebSocket] =
  newWebSocket(request.getNativeReq(), protocol = protocol)

router api:
  get "/people": resp %*getPeople()

  put "/person/@name":
    let rawName: TaintedString = @"name"
    if not nameExists(rawName.string): halt Http404

    let jsonNode = parseJson request.body
    debug jsonNode

    let person = person.fromJson jsonNode
    if not(person.name == rawName.string): halt Http422

    updatePerson person
    publishUpdates()
    resp Http204

  post "/client/@client_id/up":
    resp %*{
      "mqtt": {
        "host": mqtt.host,
        "port": mqtt.port,
        "client_id": @"client_id",
        "heartbeat_payload": {"client_id": @"client_id"},
        "topics": mqtt.topics,
      }
    }

router web:
  get "/":
    let forms = getPeople().map(renderPerson)
    resp renderIndex(forms[0], forms[1])

  get "/scantake":
    try:
      if not existsEnv("SCANTAKE_BASIC_AUTH"):
        let msg = "Missing auth. Must configure SCANTAKE_BASIC_AUTH"
        error msg
        raise Exception.newException msg
      block:
        var headerVal : string = request.headers.getOrDefault("authorization")
        headerVal.removePrefix("Basic ")
        if getEnv("SCANTAKE_BASIC_AUTH") != base64.decode(headerVal):
          raise Exception.newException "Nope!"
      resp Http200, """
        <style>
          .visually-hidden {
            position: absolute !important;
            height: 1px;
            width: 1px;
            overflow: hidden;
            clip: rect(1px, 1px, 1px, 1px);
          }

          /* Separate rule for compatibility, :focus-within is required on modern Firefox and Chrome */
          input.visually-hidden:focus + label {
            outline: thin dotted;
          }
          input.visually-hidden:focus-within + label {
            outline: thin dotted;
          }
          .fake-link:hover {
            cursor: pointer;
          }
        </style>

        <script>
          document.addEventListener("DOMContentLoaded", function() {
            document.
              getElementById("fileElem").
              addEventListener("change", handleFiles, false);
          });

          function handleFiles() {
            const fileList = this.files;
            document.getElementById("fileSubmit").disabled = fileList.length === 0;
            const ul = document.getElementById("selectedFiles");
            ul.innerHTML = "";

            for (let i = 0; i < fileList.length; i++) {
              const file = fileList[i];
              const li = document.createElement("li");
              li.appendChild(document.createTextNode(file.name));

              const ul_ = document.createElement("ul");

              let li_ = document.createElement("li");
              li_.appendChild(document.createTextNode(file.type));
              ul_.appendChild(li_);

              li_ = document.createElement("li");
              li_.appendChild(document.createTextNode(file.size + " bytes"));
              ul_.appendChild(li_);

              li.appendChild(ul_);
              ul.appendChild(li);
            }
          }
        </script>

        <form action="$1" method="post" enctype="multipart/form-data">
          <input type="file" id="fileElem" name="file" accept="image/*,application/pdf" class="visually-hidden">
          <h1>
            <a href="#">
              <label class="fake-link" for="fileElem">Select a file</label>
            </a>
          </h1>
          <ul id="selectedFiles">
          </ul>
          <input id="fileSubmit" type="submit" value="Submit file(s)" disabled />
        </form>
      """ % [uri("/submit_file", absolute = false)]
    except Exception:
      request.send Http401, @({"WWW-Authenticate": "Basic"}), ""
      return

  post "/submit_file":
    let file = request.formData["file"]
    let newName = "__TMP__" & file.fields["filename"]
    writeFile(newName, file.body)
    redirect "/file_submitted"

  get "/file_submitted":
    resp Http200, """
      <style>
        a, a:visited {
          color: blue;
        }
      </style>
      <h1>Okeydokey, got it!</h1>
      <a href="/scantake">Do another…?</a>
    """

  get "/ws":
    const supportedProtocol = "REFRESH"
    let ws = await mkWebSocket(request, protocol = supportedProtocol)
    if ws.protocol != supportedProtocol:
      await ws.send("Bad protocol")
      ws.close()
      resp Http400
    else:
      wsAdd ws
      resp Http101

  # I'd like for this to be PUT, but browser forms are GET and POST only
  post "/person/@name":
    let status = status.fromIsOnCall parseBool(request.params["is_on_call"])
    let person = Person(name: @"name", status: status)
    updatePerson person
    publishUpdates()
    redirect "/"

routes:
  extend web, ""
  extend api, "/api"

runForever()
