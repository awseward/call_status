GET {{url}}/

HTTP/* 200
[Asserts]
header "Content-Type" contains "text/html;"
header "Content-Type" contains "charset=utf-8"


GET {{url}}/api/people

HTTP/* 200
[Asserts]
header "Content-Type" contains "application/json"
