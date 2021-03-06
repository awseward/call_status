import httpClient
import httpCore
import json
import uri

import ./models/person
import ./logs

type ApiClient* = object
  baseUri: Uri

proc newApiClient*(baseUrl: string): ApiClient =
  ApiClient(baseUri: parseUri baseUrl)

proc sendJson*(api: ApiClient, httpMethod: HttpMethod, relativeUrl: string, bodyJson: JsonNode = nil): Response =
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

  # This doesn't seem great, but it works (I'm not having the best of times
  # debugging it at the moment...)
  if result.status != "204 No Content" and result.body != "":
    debug result.body

proc getPeople*(api: ApiClient): seq[Person] =
  let response = api.sendJson(HttpGet, "/api/people")
  person.fromJsonMany parseJson(response.body)

proc updatePerson*(api: ApiClient, person: Person) =
  discard api.sendJson(HttpPut, "/api/person/" & person.name, %*person)
