import httpClient
import httpCore
import json
import logging
import uri

import ./models/person

type ApiClient* = object
  baseUri: Uri

proc newApiClient*(baseUrl: string): ApiClient =
  ApiClient(baseUri: parseUri baseUrl)

proc sendJson(api: ApiClient, httpMethod: HttpMethod, relativeUrl: string, bodyJson: JsonNode = nil): Response =
  let uri = api.baseUri / relativeUrl
  let body = $bodyJson
  let http = block:
    let c = newHttpClient()
    c.headers = newHttpHeaders {
      "Content-Type": "application/json",
      "Accept": "application/json",
    }
    c
  debug httpMethod, " ", uri, " ", body
  result = http.request(
    url = $uri,
    httpMethod = httpMethod,
    body = body
  )
  if is4xx(result.code) or is5xx(result.code):
    raise newException(HttpRequestError, $result.status)
  debug result.status
  if result.body != "": debug result.body


proc getPeople*(api: ApiClient): seq[Person] =
  # The relative path is a little weird, but it's fine for now
  let response = api.sendJson(HttpGet, "/api/people")
  person.fromJsonMany parseJson(response.body)

proc updatePerson*(api: ApiClient, person: Person) =
  discard api.sendJson(HttpPut, "/api/person/" & person.name, %*person)
