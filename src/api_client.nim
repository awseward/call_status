import httpClient
import json
import logging

proc postStatus*(apiBaseUrl: string, user: string, isOnCall: bool): Response =
  let url = apiBaseUrl & "/api/status"
  let body = $ %*{"user": user, "is_on_call": isOnCall}
  let client = block:
    let c = newHttpClient()
    c.headers = newHttpHeaders {"Content-Type": "application/json"}
    c
  debug "POST " & url & " " & body
  let response = client.post(url, body = $ %*{
    "user": user,
    "is_on_call": isOnCall,
  })
  debug response.status
  if response.body != "": debug response.body

  response
