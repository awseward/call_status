GET {{base_url}}/
HTTP/* 200
[Asserts]
header "Content-Type" contains "text/html;"
header "Content-Type" contains "charset=utf-8"

# ---

PUT {{base_url}}/api/person/_n_o_n_s_e_n_s_e_
HTTP/* 404

# ---

PUT {{base_url}}/api/person/D
{ "name": "D", "is_on_call": false }
HTTP/* 204

GET {{base_url}}/api/people
HTTP/* 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$[?(@.name=='D')].is_on_call" == false

# ---

PUT {{base_url}}/api/person/D
{ "name": "D", "is_on_call": true }
HTTP/* 204

GET {{base_url}}/api/people
HTTP/* 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$[?(@.name=='D')].is_on_call" == true

# ---

PUT {{base_url}}/api/person/D
{ "name": "wrong_name", "is_on_call": false }
HTTP/* 422

# ---

POST {{base_url}}/api/client/{{client_id}}/up
Content-Length: 0
HTTP/* 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.mqtt.host" exists
jsonpath "$.mqtt.port" exists
jsonpath "$.mqtt.client_id" == {{client_id}}
jsonpath "$.mqtt.heartbeat_payload" exists
jsonpath "$.mqtt.topics.people"     exists
jsonpath "$.mqtt.topics.control"    exists
jsonpath "$.mqtt.topics.heartbeat"  exists
