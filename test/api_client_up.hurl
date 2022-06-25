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
