import httpClient
import json
import logging

proc postStatus*(apiBaseUrl: string, user: string, isOnCall: bool) : Response =
  let url = apiBaseUrl & "/api/status"
  let body = $ %*{ "user": user, "is_on_call": isOnCall }
  debug ("POST " & url & " " & body)
  let client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json" })
  let response = client.post(url,
    body = ($ %*{ "user": user, "is_on_call": isOnCall })
  )
  debug response.status
  if response.body != "":
    debug response.body

  return response
