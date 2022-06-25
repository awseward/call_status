GET {{url}}/
HTTP/* 200
[Asserts]
header "Content-Type" contains "text/html;"
header "Content-Type" contains "charset=utf-8"

# ---

PUT {{url}}/api/person/_n_o_n_s_e_n_s_e_
HTTP/* 404

# ---

PUT {{url}}/api/person/D
{ "name": "D", "is_on_call": false }
HTTP/* 204

GET {{url}}/api/people
HTTP/* 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$[?(@.name=='D')].is_on_call" == false

# ---

PUT {{url}}/api/person/D
{ "name": "D", "is_on_call": true }
HTTP/* 204

GET {{url}}/api/people
HTTP/* 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$[?(@.name=='D')].is_on_call" == true

# ---

PUT {{url}}/api/person/D
{ "name": "wrong_name", "is_on_call": false }
HTTP/* 422
