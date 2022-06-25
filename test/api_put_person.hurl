PUT {{base_url}}/api/person/D
{ "name": "D", "is_on_call": false }
HTTP/* 204

GET {{base_url}}/api/people
HTTP/* 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$[?(@.name=='D')].is_on_call" == false


PUT {{base_url}}/api/person/D
{ "name": "D", "is_on_call": true }
HTTP/* 204

GET {{base_url}}/api/people
HTTP/* 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$[?(@.name=='D')].is_on_call" == true
